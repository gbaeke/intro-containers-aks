# Build a container image

Go to https://github.com/gbaeke/go-template and clone the repository. The repository contains code to create an API with Go and contains some boilerplate code for logging, OpenAPI spec generation, graceful termination of the Go web server, etc...

**Note:** this repository is a template; you can use it to create a repository for your own use

To build the container image you need container build tools. In this example, [Docker Desktop](https://www.docker.com/products/docker-desktop) is used with the Windows 10 WSL 2 back-end. This means that containers are built and run inside WSL 2 instead of Windows 10 directly.

The cloned folder contains two Dockerfiles:
- Dockerfile
- Dockerfile.distroless

You can use either file to build the container.

## Building the container

Help? [docker build reference](https://docs.docker.com/engine/reference/commandline/build/)

Build the container image and tag it for later upload to Azure Container Registry (ACR)

Tag should be:
- for ACR: something.azurecr.io/imagename:tag (e.g. gebademo.azurecr.io/gotemplate:1.0.0)
- for Docker Hub: username/imagename:tag (e.g. gbaeke/gotemplate:1.0.0)

We will later upload the image to a container registry.

Example to run from folder containing the Dockerfile:

```
docker build --tag gebademo.azurecr.io/gotemplate:1.0.0 .
```

Running the above will use **Dockerfile**

This will result in a container image **gebademo.azurecr.io/gotemplate:1.0.0** on your **local computer**.

To list the images on your computer:

```
docker images
```

The above should reveal:

```
REPOSITORY                       TAG       IMAGE ID       CREATED        SIZE
gebademo.azurecr.io/gotemplate   1.0.0     b17d30c4bd8e   3 days ago     29MB
```

## Running the container

Let's run the container locally:

```
docker run gebademo.azurecr.io/gotemplate:1.0.0
```

The container will start and the API will be served on port 8080. We cannot access the API because we need to map the container port to a host port:

```
docker run -p 8888:8080 gebademo.azurecr.io/gotemplate:1.0.0
```

You should now be able to use **curl http://localhost:8888** which results in hello.

We can change the message with an environment variable:

```
docker run -p 8888:8080 -e WELCOME=HIIIII gebademo.azurecr.io/gotemplate:1.0.0
```

We can change the port with a parameter (will also work via environment variable):

```
docker run -p 8888:8080 gebademo.azurecr.io/gotemplate:1.0.0 "--port=9999"
```

We do not want to run this in the foreground (-d):

```
docker run -dp 8888:8080 gebademo.azurecr.io/gotemplate:1.0.0
```

## Getting a shell

We cannot get a shell to gotemplate because it uses the **scratch** image. To test with another image, run Ubuntu with a pseudo terminal in the background:

```
docker run -dt ubuntu
```

Use **docker ps** to see running containers.

Run **docker exec** to get a bash shell:

```
docker exec -it CONTAINERID-or-NAME bash
```

Tip: you can use the first few letters of the container ID instead of the full ID

When you run bash like above, you will get a prompt like:

```
root@a2d5c8a54f6c:/#
```

**Note:** a2d5c8a54f6c is the name of the container and also its hostname

