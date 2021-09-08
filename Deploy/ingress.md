# Ingress

You can use services of type LoadBalancer for your applications but that poses some problems:
- secure traffic: if you want your pods to offer https, you will need to configure this at the pod level; to reduce management overhead and as a general best practice, this should be avoided
- traffic inspection: an Azure Load Balancer does not inspect traffic (e.g. web application firewalling)
- multitude of external IPs

With an **Ingress Controller** we can tackle some of the above problems. An **Ingress Controller** is software running in Kubernetes that watches for objects of type **Ingress**. These objects define how incoming requests to a **reverse proxy** should be handled and mapped to internal services. The **Ingress Controller** then configures the reverse proxy accordingly.

The **Ingress Controller** and **reverse proxy** are often both running in the Kubernetes cluster but that does not have to be the case. The **Ingress Controller** can run in the cluster and the **reverse proxy** can run outside the cluster. This is the case when you use **Azure Application Gateway** as your Kubernetes ingress solution:

![agic](agic.png)

In the above picture:
- AGIC = Application Gateway Ingress Controller; runs on Kubernetes and watches Ingress objects; configures AG via ARM
- AG = Azure Application Gateway; configured via ARM by AGIC; will point to IP addresses of pods directly

## Installing Nginx Ingress Controller

Instead of AGIC and AG, you can also use open source Ingress Controllers like Nginx Ingress Controller. See https://kubernetes.github.io/ingress-nginx/ for full information.

Installation can be as simple as:

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.0/deploy/static/provider/cloud/deploy.yaml
```

Or install with Helm:

```
export NAMESPACE=ingress-basic
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --create-namespace --namespace $NAMESPACE
```

**Note:** this is a basic installation; see https://docs.microsoft.com/en-us/azure/aks/ingress-basic for more information

## Creating Ingress objects

Below is an example of an Ingress object (deployment not shown):

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /testpath
        pathType: Prefix
        backend:
          service:
            name: test
            port:
              number: 80
```


