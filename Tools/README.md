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
- [Octant](https://octant.dev/): developer-centric web interface for Kubernetes; has plugins for extensibility, similar to Lens (see below)

The above tools do not require a server-side component. They talk to the Kubernetes API server just like kubectl and require a kube config file. They do not need installation. They're just executables you need to run.

For cluster management of AKS, don't forget the built-in management capabilities in the **Kubernetes resources** section of your cluster in the portal.

Some tools that require installation (usually just a container or simply an installer):
- [Rancher](https://rancher.com/quick-start/)
- [Portainer](https://www.portainer.io/)
- [Lens](https://k8slens.dev/): Lens also has extensions. One such extension is Starboard, which allows you to view vulnerability reports etc... from Lens. The extension only view such reports. You will still need to install and configure Starboard on your cluster (or just use the Starboard CLI). Note there also is a Starboard plugin for Octant (see above)

## Kubectl plugins

kubectl, the Kubernetes CLI, supports plugins. To manage these plugins, you can use [krew](https://krew.sigs.k8s.io/docs/user-guide/setup/install/). Once krew is installed and updated (kubectl krew update), you can install plugins with **kubectl krew install PLUGINNAME**.

**Tip:** if you have [Homebrew](https://docs.brew.sh/Homebrew-on-Linux) installed, easily install krew with `brew install krew`

Some plugins I use:

- ns: easily set your default namespace (e.g. kubectl ns kube-system)
- ctx: easily set your context to switch between clusters (e.g. kubectl ctx CONTEXTNAME)
- nginx-ingress: work with nginx-ingess (e.g. kubectl nginx-ingress logs, )
- view-cert: view certificate information in a secret
- view-secret: easily decode secrets (remember, secrets are only base64 encoded, not encrypted)
- starboard: starboard allows you to run vulnerability scans on container images in your cluster, run audit checks and run CIS Kubebench reports (see also starboard plugin/extension for tools like Octant and Lens)

There are many more: use `kubectl krew search` to list plug-ins

