# ⚙️ **K3s-OpenFaaS setup**

This repository contains configuration files, manifests, and scripts for deploying [OpenFaaS](https://github.com/openfaas/faas) on a lightweight [K3s](https://github.com/k3s-io/k3s) Kubernetes cluster

## 📦 **What’s Inside**
- Installation scripts for K3s and OpenFaaS
- Basic usage examples and test functions

## 🖧 **Cluster Topology**
The K3s cluster in this setup consists of 3 nodes, communicating over a private network (`10.73.4.0/24`):

| Role       | Hostname   | IP Address    |
|------------|------------|---------------|
| Master     | master     | `10.73.4.40`  |
| Worker 1   | worker1    | `10.73.4.41`  |
| Worker 2   | worker2    | `10.73.4.42`  |

## 🛠️ **Setup & Installation**

### 🚀 Quick Start
1. Clone this repo on all of your nodes:
   ```bash
   git clone https://github.com/justkow/k3s-openfaas-setup.git
   ```
1. Initialize system settings
   - On `master` node:
      ```bash
      ./initial_setup.sh master1
      ```
   - On `worker` nodes respectively:
      ```bash
      ./initial_setup.sh worker1
      ```
      ```bash
      ./initial_setup.sh worker2
      ```
2. Create `token` file with k3s token of your selection on all of your nodes (the token should be the same on master and workers):
   ```bash
   echo "your_token" > token
   ```
3. Install `k3s` on every node. The argument to the script is master node IP address:
   ```bash
   ./install_k3s.sh 10.73.4.40
   ```
   After installation, run this command to make sure that the process of setting up the cluster was successful:
   ```bash
   sudo kubectl get nodes
   ```
   The output should be similar to this:
   ```bash
   NAME      STATUS   ROLES                  AGE     VERSION
   master1   Ready    control-plane,master   10m     v1.32.4+k3s1
   worker1   Ready    <none>                 2m15s   v1.32.4+k3s1
   worker2   Ready    <none>                 4s      v1.32.4+k3s1
   ```
4. Install `docker` on `master` node:
   ```bash
   ./install_docker.sh
   ```
### ▶️ How to use
