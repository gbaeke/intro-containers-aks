# Exercise 1

Clone the repo and cd into the cloned directory:

```
git clone https://github.com/gbaeke/super-api.git && cd super-api
```

Build the image with the following command:

```
docker build --tag DOCKERID/super .
```

After the image is built, use `docker image inspect DOCKERID/super`:
- was the image built with BuildKit? Check the comment.

Run a container from the image with the following command:

```
docker run --rm -dp 8080:8080 DOCKERID/super
```

Check if the container is running with `docker container ls`.

Using `docker image inspect`, what is:
- the size of the image?
- the number of layers in the image? why?

Retrieve the logs of the running container with `docker logs <CONTAINERID>`.

Hit the API with `curl http://localhost:8080` and check the response `Hello from Super API`.

Stop and remove the container:
- use `docker container stop <CONTAINERID>`

Run the container again but with the WELCOME environment variable set to a message of your choosing:

```
docker run --rm -dp 8080:8080 -e WELCOME='Hello from K8S Course' DOCKERID/super
```

Can you override entrypoint in the above command? The answer would be yes but there is not much point as there is only one executable in the image.

As an example, here is how you set the entrypoint AND extra command line arguments. This app can be given parameters like --port and --log=true/false:

```
docker run -itp 8080:9090 -e WELCOME='Hello from K8S Course' --entrypoint /app DOCKERID/super --port=9090 --log=true
```

**Note:** entrypoint can be overridden with --entrypoint. To pass arguments to the entrypoint, just add them after the image name. The above command runs Super API on port 9090. The port mapping is changed accordingly.

# Exercise 2

Tag the image:

```
docker tag DOCKERID/super DOCKERID/super:v1
```

Now chech your images with `docker image ls`. The new `reporitory` and `tag` should be in the list. The `IMAGE ID` is the same as DOCKERID/super because it was not changed.

Login to Docker Hub with `docker login`.

Push the image to Docker Hub with:

```
docker push DOCKERID/super:v1
```

Check Docker Hub. Can you find `DOCKERID/super:v1`? What about `DOCKERID/super:latest`? You will need to tag the image with `docker tag DOCKERID/super:v1 DOCKERID/super:latest` and push `DOCKERID/super:latest` to Docker Hub.


# ACR

Create an Azure Container Registry (ACR) from the portal:
- Basic SKU
- Public access
- Standard encryption at rest


When created, check the repositories. There are none for now.

Login to ACR with Azure CLI:

```
az acr list -o table

az acr login --name ACRNAME
```

The `az acr login` command should result in `Login Succeeded`.

Let's put an image in the container registry:

```
az acr import --name gebacourse --source docker.io/library/ubuntu:latest \
    --image ubuntu:latest
```

⚠️ az acr import is an easy way to import images from other registries

You should now have an image repository called `ubuntu` in the registry. There is one artifact in the repository called `latest`:

- can you find the digest of the image?
- the manifest is somewhat larger because `az acr import` imports images for all architectures (amd64, arm, arm64, etc.)

Tag the super image with the following command:

```
docker tag DOCKERID/super:latest ACRNAME.azurecr.io/super:latest
```

Now push the image to ACR with the following command:

```
docker push ACRNAME.azurecr.io/super:latest
```

Check the repositories from the command line:

```
az acr repository list --name ACRNAME
```

Run an ACR Quick Task (from the super-api folder):

```
az acr build --image super:v1 --registry ACRNAME --file Dockerfile .
```

Above, the two-stage super-api build is now performed in the cloud by an ACR Task. The logs you see in the terminal are stored by ACR as well. See the `Tasks` tab in the portal.

The result of the task should be a new repository called `super`.