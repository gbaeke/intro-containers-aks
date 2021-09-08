# Services

A pod has an IP address allowing you to connect to it. When pods are deployed via a deployment, but a pod crashes or a node crashes, the pod gets recreated. The IP address of the new pod is likely to be different.

A service solves this problem by providing a ClusterIP that does not change during the lifetime of the service. A service also has a name that can be resolved by Kubernetes DNS (AKS uses CoreDNS).

Like a deployment, a service has a selector that uses a label that matches with the pods that need be be behind the service.

![Services](Deploy/services-k8s.png)

Example service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: service-simple-service
spec:
  selector:
    app: service-simple-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

**Note:** the type of service is not specified; it will default to ClusterIP

A service can expose multiple ports:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: multi-port-service-service
spec:
  selector:
    app: MyApp
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 8080
    - name: https
      protocol: TCP
      port: 443
      targetPort: 8443
```

A service can use a load balancer. In a cloud environment like Azure, Kubernetes (AKS) is integrated with the cloud provider to provide either an external or internal Azure load balancer.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: service-load-balancer-service
spec:
  selector:
    app: MyApp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
  type: LoadBalancer
```

The above manifest would use an Azure load balancer that allows you to reach the Kubernetes service using a public IP tied to the load balancer.

If you want an internal Azure load balancer, an **annotation** takes care of that:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: internal-app
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: internal-app
```

**Note:** this load balancer is automatically created; you can specify a fixed IP address for the internal load balancer (from the AKS subnet); you can specify a different subnet for the ILB; see https://docs.microsoft.com/en-us/azure/aks/internal-lb for more information


