# ⚙️ K3s-OpenFaaS setup

This repository contains configuration files, manifests, and scripts for deploying [OpenFaaS](https://github.com/openfaas/faas) on a lightweight [K3s](https://github.com/k3s-io/k3s) Kubernetes cluster

## 📦 What’s Inside
- Installation scripts for K3s and OpenFaaS
- Basic usage examples and test functions

## 🖧 Cluster Topology
The K3s cluster in this setup consists of 3 nodes, communicating over a private network (`10.73.4.0/24`):

| Role       | Hostname   | IP Address    |
|------------|------------|---------------|
| Master     | master     | `10.73.4.40`  |
| Worker 1   | worker1    | `10.73.4.41`  |
| Worker 2   | worker2    | `10.73.4.42`  |

## Requirements
1. Each node should have unique `hostname`
2. Run `initial_setup.sh` script
