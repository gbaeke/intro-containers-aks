# Deployments

You will rarely deploy just pods. One reason is that, when a node crashes, the pod will not be recreated.

When you deploy an application, you usually want to specify things like:
- how many instances should be deployed?
- how should your application be upgraded?
    - destroy all pods and create new ones?
    - destory old pods and create new pods one at a time?
    - ...

A deployment lets you do that. A deployment uses another concept, a replicaset, to maintain the number of pods that you specified. If you specified two instances, the replicaset ensures that two instances are running.

So deployment --> replicaset --> pods

## Creating a deployment

A simple deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployments-simple-deployment-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: deployments-simple-deployment-app
  template:
    metadata:
      labels:
        app: deployments-simple-deployment-app
    spec:
      containers:
        - name: busybox
          image: busybox
          command:
            - sleep
            - "3600"
```

Notes:
- there is no explicit link between the deployment and its pods other than matching labels; in this case the label is **deployments-simple-deployment-app**.
- a deployment uses a template in the specification (spec); pods are created based on this template
- the deployment spec contains **replicas** to specify the number of instances; you do not see a reference to a ReplicaSet; under the hood, a ReplicaSet is used

Another example, from go-template, with 

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: go-template-deployment
  labels:
    app: go-template
spec:
  replicas: 2
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
          securityContext:
            runAsUser: 10000
            runAsNonRoot: true
            readOnlyRootFilesystem: true
            capabilities:
              drop:
                - all
          args: ["--port=8080"]
          ports:
            - containerPort: 8080
          resources:
              requests:
                memory: "64Mi"
                cpu: "250m"
              limits:
                memory: "64Mi"
                cpu: "250m"
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 5
          readinessProbe:
              httpGet:
                path: /readyz
                port: 8080
              initialDelaySeconds: 5
              periodSeconds: 5
```

The above manifest introduces some extra concepts:
- securityContext: implements some of the best practices such as not running as root, read-only filesystem, dropping Linux capabilities
- args: arguments passed to the container process; use high ports
- resource requests and limits
- liveness and readiness probes

