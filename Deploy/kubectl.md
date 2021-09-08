# Kubectl is the Kubernetes CLI

In what follows we configure kubectl to connect to Azure Kubernetes Service (AKS).

## Installing kubectl

See https://kubernetes.io/docs/tasks/tools/ for more information.

You can also install kubectl with the Azure CLI.

## Connecting to your AKS cluster

Use the Azure CLI to create/update your config file in the .kube folder:

```
az aks get-credentials -n CLUSTERNAME -g RESOURCEGROUP --admin
```

**Note:** if you want/need to use Azure AD authentication, do not use --admin; you will be prompted for credentials later; --admin uses client certificate to access AKS with full admin credentials; the potential use of --admin can be forbidden

After running the command, check config in the $HOME/.kube

You can now run commands such as:
- kubectl get nodes
- kubectl get namespaces
- kubectl get pods -n kubesystem
- kubectl get deployments
- kubectl get service
- kubectl apply -f yamlfile.yaml
- kubectl apply -f .
- ...

**Tip:** if you do not like typing commands like this all the time but want to stay in your shell, use a tool like k9s: https://github.com/derailed/k9s

**Tip:** if you want to use a management UI in the browser, you can also use octant: https://github.com/vmware-tanzu/octant
