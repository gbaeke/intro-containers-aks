# Tools

## Local Kubernetes

- [kind](https://kind.sigs.k8s.io/)
- [k3s](https://k3s.io/) with [k3d](https://k3d.io/v4.4.8/)
- [minikube](https://minikube.sigs.k8s.io/docs/)
- [Kubernetes with Docker Desktop](https://docs.docker.com/desktop/kubernetes/)

I usually use kind but that is just habit. kind (and minikube as well) can be resource hungry. If you want things more lightweight, just use k3s. 

**Tip:** a great tool to deploy k3s to a VM in the cloud or on your local machine is [k3sup](https://github.com/alexellis/k3sup)

## Cluster management

- [K9S](https://github.com/derailed/k9s): terminal UI to manage Kubernetes
- [Octant](https://octant.dev/): developer-centric web interface for Kubernetes

The above tools do not require a server-side component. They talk to the Kubernetes API server just like kubectl and require a kube config file.

For cluster management of AKS, don't forget the built-in management capabilities in the **Kubernetes resources** section of your cluster in the portal.

Some tools that require installation (usually just a container):
- [Rancher](https://rancher.com/quick-start/)
- [Portainer](https://www.portainer.io/)

## Kubectl plugins

kubectl, the Kubernetes CLI, supports plugins. To manage these plugins, you can use [krew](https://krew.sigs.k8s.io/docs/user-guide/setup/install/). Once krew is installed and updated (kubectl krew update), you can install plugins with **kubectl krew install PLUGINNAME**.

**Tip:** if you have [Homebrew](https://docs.brew.sh/Homebrew-on-Linux) installed, easily install krew with `brew install krew`

Some plugins I use:

- ns: easily set your default namespace (e.g. kubectl ns kube-system)
- ctx: easily set your context to switch between clusters (e.g. kubectl ctx CONTEXTNAME)
- nginx-ingress: work with nginx-ingess (e.g. kubectl nginx-ingress logs, )
- view-cert: view certificate information in a secret
- view-secret: easily decode secrets (remember, secrets are only base64 encoded, not encrypted)

There are many more: use `kubectl krew search` to list plug-ins

