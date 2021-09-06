# Build and push a container with GitHub Actions

See [workflow.yml](workflow.yml)

This workflow contains the following actions:
- Check out
- Docker meta (crazy-max/ghaction-docker-meta@v1): automatically tags the image with main, latest and possibly a git tag (e.g. 0.0.2)
- Set up QEMU: provides emulation to build multi arch container images (e.g. both an AMD64 and ARM image)
- Set up Docker Buildx: CLI that makes it easy to build containers for multiple architectures in one step; also uses BuildKit as the backend for executing builds
- Login to registry: in this case, login to GitHub Container Registry
- Build and/or push image with docker/build-push-action@v2
- Check for vulnerabilities: uses snyk/actions/docker@master

There are many alternative ways to achieve the same result. Often, these steps are fully scripted as well using the same commands you saw earlier.

**Note:** if you have been using Docker Desktop on Windows in the previous sections, you also used BuildKit because it is the default way to run Docker builds; setting up Buildx ensures we use BuildKit on the GitHub runner

**Note:** you will often see authentication to GHCR with a GitHub token stored as a secret; this is not necessary anymore because you can use your GITHUB_TOKEN which is a built-in secret:

```
name: Login to GHCR
uses: docker/login-action@v1
with:
    registry: ghcr.io
    username: ${{ github.repository_owner }}
    password: ${{ secrets.GITHUB_TOKEN }}
```