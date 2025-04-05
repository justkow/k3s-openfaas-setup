# K3s-configuration


## Requirements
1. Each node should have unique `hostname`
2. Add ufw rules (Ubuntu/Debian):
    - server:
        ```bash
        ufw allow 6443/tcp #apiserver
        ufw allow from 10.42.0.0/16 to any #pods
        ufw allow from 10.43.0.0/16 to any #services
        ```
    - agents:
        ```bash
        ufw allow from 10.42.0.0/16 to any #pods
        ufw allow from 10.43.0.0/16 to any #services
        ```



## Installation
