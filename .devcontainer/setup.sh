#!/usr/bin/env bash
set -euo pipefail

# Install Mise
if ! command -v mise >/dev/null 2>&1; then
  curl https://mise.run | sh
fi

# Use Mise to install all the tools we need
cd "$(dirname "$0")"
mise trust .mise.toml
mise install

# Separately, install K3D. It's not in .mise.toml as it's only need for Codespaces
mise install k3d@5.8.3
mise use k3d