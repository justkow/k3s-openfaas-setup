#!/bin/bash

REGISTRY_IP="${1:?}:5000"
DAEMON_FILE="/etc/docker/daemon.json"
USER="${SUDO_USER:?}"
BASHRC_PATH="/home/${USER}/.bashrc"

YELLOW='\e[33m'
RESET='\e[0m'

echo -e "${YELLOW}[INFO] Installing arkade and faas-cli...${RESET}"
curl -sSL https://get.arkade.dev/ | sudo -E sh
arkade get faas-cli
sudo mv /root/.arkade/bin/faas-cli /usr/local/bin/
sudo chmod +x /usr/local/bin/faas-cli

echo -e "${YELLOW}[INFO] Creating a local Docker registry...${RESET}"
sudo docker run -d -p 5000:5000 --restart=always --name registry registry:2
sudo bash -c "cat > ${DAEMON_FILE}" <<EOF
{
  "insecure-registries": ["${REGISTRY_IP}"]
}
EOF

echo -e "${YELLOW}[INFO] Restarting Docker...${RESET}"
sudo systemctl restart docker

echo -e "${YELLOW}[INFO] Installing OpenFaaS...${RESET}"
mkdir "/home/${USER}/.kube"
sudo kubectl config view --raw >~/.kube/config
export KUBECONFIG="/home/${USER}/.kube/config"
sudo chown -R "${USER}":"${USER}" /tmp/charts
sudo arkade install openfaas

echo -e "${YELLOW}[INFO] Checking OpenFaaS gateway status...${RESET}"
sudo kubectl rollout status -n openfaas deploy/gateway

echo -e "${YELLOW}[INFO] Updating .bashrc files...${RESET}"
export OPENFAAS_URL="http://127.0.0.1:8080"
echo "export OPENFAAS_URL=\"http://127.0.0.1:8080\"" >> "${BASHRC_PATH}"

openfaas_passwd=$(sudo kubectl get secret -n openfaas basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode; echo)
echo "PASSWORD=${openfaas_passwd}" >> "${BASHRC_PATH}"

faas_login=$(cat <<'EOF'
function faas-login {
  echo -n "$PASSWORD" | faas-cli login --username admin --password-stdin
}
EOF
)
echo "${faas_login}" >> "${BASHRC_PATH}"

faas_port_forward=$(cat <<'EOF'
function faas-port-forward {
  sudo kubectl port-forward -n openfaas svc/gateway 8080:8080
}
EOF
)
echo "${faas_port_forward}" >> "${BASHRC_PATH}"
