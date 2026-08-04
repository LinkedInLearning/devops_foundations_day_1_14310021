#!/usr/bin/env bash

set -eo pipefail

# Run the app as the app-user
sudo -i -u app-user bash << 'EOF'
  cd /home/app-user/app
  export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
  nohup npm start &
EOF