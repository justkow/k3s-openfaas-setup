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

### 🧰 Scripts Overview

| Script              | Description                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| `initial_setup.sh`      | Sets hostname and adds basic UFW rules depending on node role (`master`/`worker`) |
| `install_docker.sh`  | Installs Docker Engine (required for building OpenFaaS functions locally)  |
| `install_k3s.sh`     | Installs the K3s Kubernetes distribution on the current machine            |

### 🚀 Quick Start
1. Clone this repo on all of your nodes:
   ```bash
   git clone https://github.com/pangandalf/k3s-openfaas-setup.git
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
2. Create `token` file with k3s token of your selection:
   ```bash
   echo "your_token" > token
   ```
3. Install `k3s` on every node:
   ```bash
   ./install_k3s.sh
   ```
4. Install `docker` on `master` node:
   ```bash
   ./install_docker.sh
   ```
### ▶️ How to use
