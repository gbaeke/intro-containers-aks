# Dockerfiles

## Introduction

The name of the Dockerfile is usually just that: **Dockerfile**

You can then run **docker build .** to build the container image from the folder that contains the Dockerfile.

Usually, you will tag the image with **docker build --tag tagname .**

For example:

```
docker build --tag myacr.azurecr.io/helloworld:v1 .
```

## Dockerfile_hello

Dockerfile used to create the container image for Docker Hello World. See https://github.com/docker-library/hello-world

```
FROM scratch
COPY hello /
CMD ["/hello"]
```

hello is a compiled binary we copy to the container image. It does not have any dependencies. We expect the compiled binary in the same folder as the Dockerfile. In general, it's recommended to also build and test your code in a container.

## Dockerfile_twostage

This Dockerfile is used to build and test a Go application and produce a single binary. This happens in the first stage of docker build.

In the second stage, we copy the binary and other files from the first stage to the second stage. The resulting container image is the one from the last stage. The other stage is discarded.

Note that the **Hello World** Dockerfile used CMD to indicate the process that should be run when a container is started from the image.

In this Dockerfile, we use ENTRYPOINT as follows:

```
ENTRYPOINT ["/app"]
```

The end result is the same but there is a difference between both commands. CMD is easy to override during **docker run** where ENTRYPOINT is not (requires --entrypoint flag). Usually, ENTRYPOINT is combined with CMD to always use the same process to start and to set default parameters that you can override. For instance:

```
ENTRYPOINT ["echo", "Hello"] 
CMD ["World"]
```

With the above, **docker run imagename** would print **Hello World** but **docker run imagename Geert** would print **Hello Geert**.

## Dockerfile_distroless

In the second example, we used the scratch container. The scratch container is 0 bytes so empty. That's great when you only need you binary and possibly a few extra files.

You can also use **gcr.io/distroless/static**. Distroless is a Google project that provides container images for popular languages without the overhead of a distro like Ubuntu, CentOS, etc... The images are based on Debian. Like the scratch image, they lack a shell so you cannot easily enter the running container to troubleshoot it. There are **:debug** images that provide a **busybox** shell.

Distroless static contains:
- ca-certificates
- /etc/passwd for a root user (UID 0), nobody (UID 65534), nonroot (UID 65532) 
- /tmp folder
- tzdata

This is useful for statically compiled applications that do not require libc. Otherwise use **distroless/base**

**Note:** the user your container runs with can be easily overridden at runtime and does not need to match the user(s) in /etc/passwd. For instance, with Kubernetes, use securityContext:

```
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
```

The above does not work on Windows containers: see https://kubernetes.io/docs/tasks/configure-pod-container/configure-runasusername/ 

