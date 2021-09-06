# Using ko

ko is a tool to easily build a Go binary, package it as a container, push the container and run it on Kubernetes with **go apply**

Preparation:
- run **export KO_DOCKER_REPO=docker.io/DockerID** so ko knows where to push the container; make sure Docker has credentials to the registry
- have a manifest with the image reference somewhat different 😊

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: kotest
spec:
  containers:
  - name: kotest
    image: ko://github.com/gbaeke/go-template/cmd/app
  restartPolicy: Never
```

Running ko:
- now just run **ko apply -f yourmanifest.yaml** and ko will do its magic

Output of ko apply:

```
2021/09/06 23:15:07 Using base gcr.io/distroless/static:nonroot for github.com/gbaeke/go-template/cmd/app
2021/09/06 23:15:09 Building github.com/gbaeke/go-template/cmd/app for linux/amd64
2021/09/06 23:15:18 Publishing docker.io/gbaeke/app-953856129f31a9f12e3416e25ddfc7ee:latest
2021/09/06 23:15:20 pushed blob: sha256:72164b581b02b1eb297b403bcc8fc1bfa245cb52e103a3a525a0835a58ff58e2
2021/09/06 23:15:21 pushed blob: sha256:b49b96595fd4bd6de7cb7253fe5e89d242d0eb4f993b2b8280c0581c3a62ddc2
2021/09/06 23:15:24 pushed blob: sha256:d1ce7ac985290e5c003ed7cf2f26ea1d34cc96fcedf60a084a38fb6d8b2e7e50
2021/09/06 23:15:25 pushed blob: sha256:c093a84a9c5a42f0ab94b6c07bcb15d469055d741c9419262d286dd5456f4ecd
2021/09/06 23:15:26 docker.io/gbaeke/app-953856129f31a9f12e3416e25ddfc7ee:latest: digest: sha256:38fd4cfe2dff4d0d6b599cd8f6f441657f324c84d3dce2a2c9c510f14e0c1222 size: 751
2021/09/06 23:15:26 Published docker.io/gbaeke/app-953856129f31a9f12e3416e25ddfc7ee@sha256:38fd4cfe2dff4d0d6b599cd8f6f441657f324c84d3dce2a2c9c510f14e0c1222
pod/kotest configured
```

From the above we can observe the following:
- base image is distroless/static:nonroot to explicitly use the nonroot user in the image
- ko finds the Go app at github.com/gbaeke/go-template/cmd/app and builds it
- name of the container is app-somehash:latest
- pushes the container to Docker Hub (because we set KO_DOCKER_REPO)

In Kubernetes, **kubectl get pods** results in:

```
NAME     READY   STATUS    RESTARTS   AGE
kotest   1/1     Running   0          12m
```

Other options:
- **ko publish** to just build and push an image
    - example: ko publish github.com/gbaeke/go-template/cmd/app
- **ko delete -f yourmanifest.yaml** to cleanup

**Tip:** if you use kind, set KO_DOCKER_REPO to kind.local; the image will not be pushed to a remote registry but to your kind cluster
- example: `KO_DOCKER_REPO=kind.local ko apply -f testko.yaml`

**Tip:** override defaults with ko.yaml; see https://opensourcelibs.com/lib/ko 

