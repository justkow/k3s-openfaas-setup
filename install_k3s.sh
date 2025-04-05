#!/bin/bash

function install_k3s() {
    local hostname="$(hostname)"
    local k3s_url="https://get.k3s.io"
    local k3s_token="$(cat token)"
    local server_ip="${1}"
    
    if [[ "${hostname}" =~ ^master.*$ ]]; then
        echo "Installing K3s on master node"
        curl -sfL "${k3s_url}" | K3S_TOKEN="${k3s_token}" sh -s - server
    elif [[ "${hostname}" =~ ^worker.*$ ]]; then
        echo "Installing K3s on worker node"
        curl -sfL "${k3s_url}" | INSTALL_K3S_EXEC="agent" K3S_TOKEN="${k3s_token}" sh -s - --server "https://${server_ip}"
    fi
}

install_k3s "${1}"
