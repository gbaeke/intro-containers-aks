# Module 2: Kubernetes Concepts

## Namespaces

Kubernetes namespaces are a way to organize your application into a logical group. They are used to isolate your application from other applications in the same cluster. 

Namespaces can be created with the following command:

```
kubectl create namespace <namespace>
```

Namespaces can be deleted with the following command:

```
kubectl delete namespace <namespace>        
```

Note that creating a namespace with **kubectl create** is an imperative command. It is not declarative. Creating the same namespace twice, will give you an error. In general, create your resources with a YAML file. If you need a quick introduction to YAML, check this [YAML Tutorial](https://www.cloudbees.com/blog/yaml-tutorial-everything-you-need-get-started).

To create a namespace, create the following YAML file:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: <namespace>
  labels:
    app: <app-name>
    version: <version>
    environment: <environment>
```

In the above YAML file, labels were added to identify the namespace. Labels are used to group resources in the cluster. The name of a Kubernetes resource is in the metadata.name field.

To submit the YAML file to the cluster, use the following command:

```
kubectl apply -f <YAML-file>
```

To delete a namespace, use the following command:

```
kubectl delete -f <YAML-file>
```

## Pods

Kubernetes runs one or more containers per pod. A pod is a group of containers that share the same configuration. In many cases, a pod is a single container. That single container is the application you have written. Other containers in the pod are used to support the application. For example, a web server container might be used to serve the application while another container continually updates the web server source files.

Pods on their own are not very useful. When a pod fails, it will be restarted by the kubelet on the Kubernetes node that runs the pod. You can modify that behaviour with a RestartPolicy. RestartPolicy is a field in the pod specification. When the node that runs the pod fails, the pod will not be started on another node. This can be solved by using other resources such as Deployments, ReplicaSets, or ReplicationControllers.

To create a pod imperatively, run the following command:

```
kubectl create pod <pod-name> --image=<image-name> --namespace=<namespace>
```

For example, to run an nginx pod in the test namespace, run the following command:

```
kubectl create pod nginx --image=nginx --namespace=test
```

Although you can extra flags to the above command to specify the image and namespace and more, you can also use the following YAML file to create the pod:
    
```yaml    
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app: web
  annotations:
    owner: thedev
spec:
  containers:
  - name: web
    image: nginx
    imagePullPolicy: Always
    ports:
    - containerPort: 80
      protocol: TCP
      name: web
```

When you submit the above YAML file to the cluster, the pod will be created and scheduled on one of your nodes. Since the default RestartPolicy is Always, the pod will be restarted if it fails. If the node fails, the pod will not be scheduled on another node.

The spec (or specification) of the Pod is kept deliberately simple. In other modules, you will learn to add other things to the spec such as:
- NodeSelector
- Affinity
- Tolerations
- Volumes
- Multiple containers
- Env
- EnvFrom
- InitContainers
- SecurityContext
- Resources

The above pod uses the **nginx** image to run the container. The image is pulled from Docker Hub because a specific container registry is not specified. The nginx image is a popular web server image and is a public image that anyone can pull, i.e. download. On a Kubernetes node, the kubelet is responsible for pulling the image. We will later see how to configure the kubelet to pull images from a private registry. With Azure, we can use an Azure Active Directory identity, used be the kubelet, to pull images from private registries such as Azure Container Registry.

## Deployments

Kubernetes deployments are a way to manage the pods that run your application. Deployments are used to scale up and down your application and to update the application. To scale the pods up or down, a Deployment actually uses a ReplicaSet. It delegates the scaling decisions to the ReplicaSet. The Deployment's main task is to update your application when there is a change such as a new version of the container image of the application. To update your application, a Deployment uses a DeploymentStrategy. There are two DeploymentStrategies: RollingUpdate and Recreate. See the [Deployment Strategy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#deployment-strategy) section for more information.

To create a Deployment, run the following command:

```
kubectl create deployment <deployment-name> --image=<image-name> --namespace=<namespace>
```

For example, to create a Deployment for the nginx pod in the test namespace, run the following command:

```
kubectl create deployment nginx --image=nginx --namespace=test
```

Of course, you will create deployments via YAML files. Here is an example of a Deployment in YAML:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: go-template
  labels:
    app: go-template
spec:
  replicas: 3
  selector:
    matchLabels:
      app: go-template
  template:
    metadata:
      labels:
        app: go-template
    spec:
      containers:
        - name: go-template
          image: ghcr.io/gbaeke/go-template:0.0.2
          ports:
            - name: http
              containerPort: 8080
          resources:
            requests:
              cpu: 100m
              memory: 64Mi
            limits:
              cpu: 100m
              memory: 64Mi
```

Like other resources, a Deployment has a name defined in the metadata.name field. In the Deployment spec, you can specify the number of replicas to run. The number of replicas is the number of pods that will be created by the ReplicaSet that the Deployment will create under the hood. The question is, how will the pods be created and what are the specs of the Pods? The answer is easy: the Pods are created based on the template that you specify in the Deployment spec.

In this case, the Deployment will create Pods with the following characteristics:
- one container per Pod, with name **go-template**
- the container's image is **ghcr.io/gbaeke/go-template:0.0.2**
- the container's port is **8080** with name **http**; note that this is metadata; it does not actually "open a port" on the container; the metadata can be used by other resources such as services
- the container's resources are **100m CPU, 64Mi memory** etc... We have not discussed how to set these resources yet. We have added them here to illustrate that you can set properties (and many others) in the template.

One thing to note here is the relationship between the Deployment and the Pods it creates. You need to tell the Deployment about the Pods it should manage. In this case, each pod will be given a label **app=go-template**. This label is used to identify the pods. The Deployment has a selector that specifies the pods that it should manage with a selector. In this case, a simple **matchLabels** selector is used. For more information, see [Selector](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#selector). Instead of using a simple matchLabels selector, you can use a more complex selector. For example, you can use a **matchExpressions** selector. matchExpressions supports set-based filters such as In and NotIn. For more information about matchExpressions, see [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/).

You must make sure that the selector is correct. You also have to specify the selector in the Deployment spec and the labels in the pod template.

## Service

When you deploy Pods on their own or via a Deployment, the Pods's IP address cannot be relied on. The Pod might be restarted by the kubelet or recreated on another node by a controller (e.g. a deployment controller). When that happens, the Pod's IP address might change.

To obtain a stable IP address for your Pods, use a Service. A service does two things:
- it provides a stable IP for your Pods
- it load balances the traffic to your Pods (using round robin, by default)

To create a service, you can use the following command:

```
kubectl create service <service-name> --image=<image-name> --namespace=<namespace>
```

However, it is rare to create services this way. You should use a YAML file to create the service. Here is an example of a service in YAML:

    
```yaml
apiVersion: v1
kind: Service
metadata:
  name: go-template-service
spec:
  type: ClusterIP
  selector:
    app: go-template
  ports:
  - name: http
    port: 80
    targetPort: 8080
```

Similar to a Deployment, a Service uses a selector to learn which Pods it has to send traffic to. In this case, the selector is **app=go-template**. We defined this label in spec.template.metadata.labels in the YAML file of our Deployment.

In the above case, we define that the service should listen for requests on port 80 and send them to the Pods with the label **app=go-template** on port 8080. The service will load balance the traffic to the Pods using round robin. Note that **ports** is an array. A Service can have multiple ports to listen on.

Services have a type. These types are:
- ClusterIP: the service will be assigned an internal cluster IP address. This is the default type.
- NodePort: the service will be assigned a node port, i.e. a port on each node of the cluster.
- LoadBalancer: the service will be assigned a load balancer IP address.

Our service uses the ClusterIP type. It is important to note that this IP address is reachable inside the cluster only. External clients will not be able to access the service. These external clients can be on the same network as the nodes or on a different network such as the Internet.

Later, we will see that you can use a service of type LoadBalancer to make your service accessible from outside the cluster. With Azure, the load balancer will be an Azure load balancer. It can be a public load balancer or a private load balancer.