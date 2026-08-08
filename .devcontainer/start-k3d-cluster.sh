#!/usr/bin/env bash

set -euo pipefail

cluster_name="${K3D_CLUSTER_NAME:-devops-foundations}"

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

if ! wait_for_docker; then
  exit 0
fi

if ! k3d cluster get "$cluster_name" >/dev/null 2>&1; then
  echo "Creating k3d cluster $cluster_name"
  k3d cluster create "$cluster_name" \
    --servers 1 \
    --agents 1 \
    --wait \
    --kubeconfig-update-default \
    --kubeconfig-switch-context \
    --registry-create devops-registry:5001 \
    --port "8080:8080@loadbalancer"
fi

servers_running=$(k3d cluster list --output json | jq --arg cluster_name "$cluster_name" '.[] | select(.name==$cluster_name) | .serversRunning')
if [[ "$servers_running" -eq 1 ]]; then
  echo "k3d cluster is running"
else
  echo "k3d cluster is not running. Will start it."
  k3d cluster start "$cluster_name"
fi

kubectl config use-context "k3d-$cluster_name" >/dev/null 2>&1 || true
