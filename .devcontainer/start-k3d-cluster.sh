#!/usr/bin/env bash

set -euo pipefail

cluster_name="${K3D_CLUSTER_NAME:-devops-foundations}"
network_name="k3d-${cluster_name}"

wait_for_docker() {
  local attempts=30
  local delay_seconds=2

  for ((i = 1; i <= attempts; i++)); do
    if docker info >/dev/null 2>&1; then
      return 0
    fi
    sleep "$delay_seconds"
  done

  echo "Docker did not become ready in time; skipping k3d startup." >&2
  return 1
}

prepare_network() {
  # Create the network before k3d waits for its nodes, so we can fix forwarding first.
  # Passing --network makes this an external network: k3d cluster delete will retain it.
  if ! docker network inspect "$network_name" >/dev/null 2>&1; then
    docker network create "$network_name" >/dev/null
  fi

  # Codespaces can retain legacy rules for docker0 while Docker uses iptables-nft
  # for new bridges. The legacy FORWARD DROP policy then blocks the k3d bridge.
  if [[ "${CODESPACES:-}" != "true" ]]; then
    return 0
  fi

  local bridge
  bridge=$(docker network inspect --format \
    '{{with index .Options "com.docker.network.bridge.name"}}{{.}}{{else}}br-{{printf "%.12s" .Id}}{{end}}' \
    "$network_name")

  # Run in the Docker host, not the devcontainer. Recheck on every startup because
  # host restarts can reset the rules. Leave other bridges and firewall policies alone.
  docker run --rm --privileged --pid=host alpine:3.22 \
    nsenter -t 1 -m -n -- sh -eu -c '
      bridge="$1"
      if ! command -v iptables-legacy >/dev/null 2>&1; then
        exit 0
      fi
      if ! iptables --version | grep -q "nf_tables"; then
        exit 0
      fi
      legacy_forward=$(iptables-legacy -S FORWARD)
      if ! printf "%s\n" "$legacy_forward" | grep -q "^-P FORWARD DROP$"; then
        exit 0
      fi

      ip link show "$bridge" >/dev/null
      echo "Ensuring Codespaces legacy firewall allows k3d bridge $bridge"
      iptables-legacy -C DOCKER-USER -i "$bridge" -j ACCEPT 2>/dev/null ||
        iptables-legacy -I DOCKER-USER 1 -i "$bridge" -j ACCEPT
      iptables-legacy -C DOCKER-USER -o "$bridge" -m conntrack \
        --ctstate RELATED,ESTABLISHED -j ACCEPT 2>/dev/null ||
        iptables-legacy -I DOCKER-USER 1 -o "$bridge" -m conntrack \
          --ctstate RELATED,ESTABLISHED -j ACCEPT
    ' sh "$bridge"
}

if ! wait_for_docker; then
  exit 0
fi

prepare_network

if ! k3d cluster get "$cluster_name" >/dev/null 2>&1; then
  echo "Creating k3d cluster $cluster_name"
  k3d cluster create "$cluster_name" \
    --network "$network_name" \
    --servers 1 \
    --agents 1 \
    --wait \
    --timeout 120s \
    --kubeconfig-update-default=false \
    --registry-create devops-registry:5001 \
    --port "8080:8080@loadbalancer"
else
  # Let k3d start all stopped nodes, including the agent and load balancer.
  echo "Starting k3d cluster $cluster_name"
  k3d cluster start "$cluster_name" --wait --timeout 120s
fi

# Merge on every run to repair missing kubeconfig entries for an existing cluster.
# With KUBECONFIG unset, k3d uses the current user's ~/.kube/config.
k3d kubeconfig merge "$cluster_name" \
  --kubeconfig-merge-default \
  --kubeconfig-switch-context >/dev/null
