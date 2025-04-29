#!/bin/bash

REGISTRY_IP="10.73.4.40:5000"
DAEMON_FILE="/etc/docker/daemon.json"

curl -sSL https://get.arkade.dev/ | sudo -E sh
arkade get faas-cli
sudo mv "/home/${USER}/.arkade/bin/faas-cli" /usr/local/bin/
faas-cli version

# Create a local registry
sudo docker run -d -p 5000:5000 --restart=always --name registry registry:2

sudo bash -c "cat > $DAEMON_FILE <<EOF
{
  \"insecure-registries\": [\"$REGISTRY_IP\"]
}
EOF"
sudo systemctl restart docker

#sudo docker tag hello-world 10.73.4.40:5000/hello
#sudo docker push 10.73.4.40:5000/hello
#sudo docker pull 10.73.4.40:5000/hello

echo 'export OPENFAAS_PREFIX="10.73.4.40:5000"' >> ~/.bashrc
