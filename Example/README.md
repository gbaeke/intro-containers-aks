# Example

## Namespace

We will create a namespace for the app. You can use `kubectl create ns` or a manifest:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: go-template
```

Apply the manifest with `kubectl apply`

## Deployment

We will deploy gbaeke/go-template:0.0.2 to the cluster. Use 2 replicas and do not run as root. Set some limits on the pods, they can be low.

deployment.yaml contains an example.

## Service

We will make the service available on the Internet via ingress. We need a service with a ClusterIP first.

See service.yaml for an example.

## Ingress

**Note:** this requires the installation of an Ingress Controller like Nginx Ingress Controller; to install:

```
export NAMESPACE=ingress-basic
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --create-namespace --namespace $NAMESPACE
```

We use a host-based ingress here. The incoming request in analyzed and mapped to a backend service. In this case (check ingress.yaml), we use **nip.io** to get a hostname for the public IP address of the Ingress Controller.

⚠ **Replace the IP address in the hostname with the IP address of your Ingress Controller's service**

You should now be able to curl app.IPADDRESS.nip.io and get **hello** back.