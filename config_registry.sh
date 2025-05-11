#!/bin/bash

REGISTRY_IP="${1:?}"
REGISTRY_PORT="5000"
CONFIG_PATH="/etc/rancher/k3s"
CONFIG_FILE="$CONFIG_PATH/registries.yaml"

mkdir -p "$CONFIG_PATH"

cat <<EOF > "$CONFIG_FILE"
mirrors:
  "$REGISTRY_IP:$REGISTRY_PORT":
    endpoint:
      - "http://$REGISTRY_IP:$REGISTRY_PORT"
EOF

systemctl daemon-reexec
systemctl restart k3s-agent

echo "Docker registry configuration for K3s agent has been updated."
echo "Please ensure that the Docker registry is running and accessible at $REGISTRY_IP:$REGISTRY_PORT."
echo "You can verify the configuration by checking the contents of $CONFIG_FILE."
