# Local Kubernetes

There are many options to run Kubernetes locally:

- minikube
- Kubernetes integrated with Docker Desktop
- kind
- k3s
- ...

We will create a Kubernetes cluster with [kind](https://kind.sigs.k8s.io/). kind stands for **Kubernetes in Docker** and requires Docker on your local machine. You also need the kind executable. Check the docs for installation.

**TIP:** also make sure you have **kubectl** installed

## Create a cluster

Just run the following command:

```
kind create cluster
```

This creates a default cluster with one node. Your kube config file will be changed to connect to this cluster.

Run **kubectl get nodes** to see the deployed nodes:

```
NAME                 STATUS     ROLES                  AGE   VERSION
kind-control-plane   NotReady   control-plane,master   29s   v1.21.1
```

**Note:** it can take a moment for the node to be **Ready**

## Creating a custom cluster

You can use a YAML config file to configure kind cluster creation. See https://kind.sigs.k8s.io/docs/user/configuration/ for more information.

Example:

```yaml
kind: Cluster
apiVersion: kind.sigs.k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
  - role: worker
```