# ⚙️ **K3s-OpenFaaS setup**

This repository contains configuration files and scripts for deploying [OpenFaaS](https://github.com/openfaas/faas) on a lightweight [K3s](https://github.com/k3s-io/k3s) Kubernetes cluster. Additionally, it includes example Python functions and monitoring setup using [Prometheus](https://github.com/prometheus/prometheus) and [Grafana](https://github.com/grafana/grafana).

## 📑 Table of Contents
1. [Cluster Topology](#-cluster-topology)
2. [Quick Start](#-quick-start)
3. [Running Python functions](#️-running-python-functions)
   - [Creating first function](#simple-hello-world-function)
   - [Calculating prime numbers](#cpu-intensive-function-for-calculating-prime-numbers)
4. [Monitoring](#-monitoring)
   - [Prometheus with cAdvisor](#configuring-prometheus-with-cadvisor)
   - [Grafana]

## 🖧 **Cluster Topology**
The K3s cluster in this setup consists of 3 nodes, communicating over a private network (`10.73.4.0/24`):

| Role       | Hostname   | IP Address    |
|------------|------------|---------------|
| Master     | master     | `10.73.4.40`  |
| Worker 1   | worker1    | `10.73.4.41`  |
| Worker 2   | worker2    | `10.73.4.42`  |

## 🚀 Quick Start
1. Clone this repo on all of your nodes:
   ```bash
   git clone https://github.com/justkow/k3s-openfaas-setup.git
   ```
2. Initialize system settings
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
3. Create `token` file with k3s token of your selection on all of your nodes (the token should be the same on master and workers):
   ```bash
   echo "your_token" > token
   ```
4. Install `k3s` on every node. The argument to the script is master node IP address:
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
5. Install `docker` on master node:
   ```bash
   ./install_docker.sh
   ```
6. Install `OpenFaaS` on master node (provide master IP address as the argument for the script)
   > Note: If you run the script multiple times, you have to clean your .bashrc file manually
   ```bash
   sudo ./install_openfaas.sh 10.73.4.40
   ```
   To verify if installation was successful run:
   ```bash
   sudo kubectl get pods -n openfaas -o wide
   ```
   The output should look like this:
   ![OpenFaaS pods](images/pods.png)
7. Configure Docker registry on all of the nodes:
   ```bash
   sudo ./config_registry.sh 10.73.4.40
   ```

## ▶️ Running Python functions
All operation in this section are performed on master node. First you have to forward local port to OpenFaaS gateway service:
```bash
faas-port-forward
```
Then login to OpenFaaS:
```bash
faas-login
```
To run your serverless functions, you need to pull proper template from OpenFaaS repository. For our usecases, the `python-http` template will be used:
```bash
faas-cli template store pull python3-http
```

### Simple "Hello world!" function
Create the function by running command:
```bash
faas-cli new hello-world --lang python3-http
```

The function code is in the `hello-world/handler.py` file. You can modify it to return e.g.: "Hello world!"
```python
def handle(event, context):
    return "Hello world!\n"
```

Then you have to modify `stack.yaml` by adding address to your local Docker registry. The final `stack.yaml` should look like this:
```yaml
version: 1.0
provider:
  name: openfaas
  gateway: http://127.0.0.1:8080
functions:
  hello-openfaas:
    lang: python3-http
    handler: ./hello-world
    image: 10.73.4.40:5000/hello-world:latest
    imagePullPolicy: IfNotPresent
```

Finally you have to:
1. Build image with the function
   ```bash
   sudo faas-cli build -f stack.yaml
   ```
2. Push it to the local Docker registry
   ```bash
   sudo faas-cli push -f stack.yaml
   ```
3. Deploy the function
   ```bash
   faas-cli deploy -f stack.yaml
   ```

You can verify if the pod with the function was created correctly by running command:
```bash
sudo kubectl get pods -n openfaas-fn -o wide
```
The output should look similar to this:
![Hello world](images/hello_world.png)

Now test you function by running:
```bash
echo "" | faas-cli invoke hello-world
```

### CPU-intensive function for calculating prime numbers
Append `prime-numbers` function to `stack.yaml` file
```bash
faas-cli new --append stack.yaml prime-numbers --lang python3-http
```

Add registry information to the `stack.yaml`, so the functions section for `prime-numbers` looks like this:
```yaml
functions:
  prime-numbers:
    lang: python3-http
    handler: ./prime-numbers
    image: 10.73.4.40:5000/prime-numbers:latest
    imagePullPolicy: IfNotPresent
```

Copy `handler.py` file from this repository to your function directory
```bash
cp k3s-openfaas-setup/functions/prime-numbers/handler.py prime-numbers/handler.py
```

Then build, push, deploy and invoke the function
```bash
sudo faas-cli build -f stack.yaml
sudo faas-cli push -f stack.yaml
faas-cli deploy -f stack.yaml
echo "" | faas-cli invoke prime-numbers
```

## 📊 Monitoring
`Prometheus` is deployed by default as a pod, while installing OpenFaaS.

`cAdvisor` is included in the `cubectl` tool. You can test it by running e.g.:
```bash
sudo kubectl get --raw /api/v1/nodes/worker1/proxy/metrics/cadvisor
```

### Configuring Prometheus with cAdvisor
`cAdvisor` provides valuable performance metrics e.g.: CPU and memory usage per function. In order `Prometheus` to be able to read these metrics, proper permissions have to be configured.

1. Grant the openfaas-prometheus service account permission to access node metrics, logs, and proxy data for monitoring
   ```bash
   sudo kubectl apply -f k3s-openfaas-setup/manifests/prometheus-clusterrole.yaml
   ```
   ```bash
   sudo kubectl apply -f k3s-openfaas-setup/manifests/prometheus-clusterrolebinding.yaml
   ```
2. Configure cAdvisor targets for Prometheus
   ```bash
   sudo kubectl -n openfaas delete configmap prometheus-config
   ```
   ```bash
   sudo kubectl -n openfaas apply -f k3s-openfaas-setup/manifests/prometheus-config.yaml
   ```
3. Restart Prometheus pod
   ```bash
   sudo kubectl rollout restart deployment prometheus -n openfaas
   ```