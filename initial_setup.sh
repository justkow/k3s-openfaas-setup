#!/bin/bash

function set_hostname() {
    local hostname="${1}"
    echo "Setting hostname to ${hostname}"
    hostnamectl set-hostname "${hostname}"
}

function add_ufw_rule() {
    local hostname="${1}"
    ufw allow ssh
    if [[ "${hostname}" =~ ^master.*$ ]]; then
        echo "Adding UFW rules for master node"
        ufw allow 6443/tcp #apiserver
        ufw allow from 10.42.0.0/16 to any #pods
        ufw allow from 10.43.0.0/16 to any #services
    elif [[ "${hostname}" =~ ^worker.*$ ]]; then
        echo "Adding UFW rules for worker node"
        ufw allow from 10.42.0.0/16 to any
        ufw allow from 10.43.0.0/16 to any
    fi
    ufw reload
}

function run() {
    local hostname="${1}"
    set_hostname "${hostname}"
    
    if command -v ufw &>/dev/null; then
        add_ufw_rule "${hostname}"
    fi
}

run "${1}"
