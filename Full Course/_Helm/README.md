# Helm

## Installing Helm

Install Helm from https://github.com/helm/helm/releases or use an installer like Chocolatey or brex. E.g., `brew install helm`

Run `helm version` to check the installed version.

## Installing charts


### Basics: installing and uninstalling a chart from a repo

Charts are installed from repositories or directly from the filesystem. A chart repository is just a web server with packages charts and an `index.yaml` file.

See https://github.com/gbaeke/helm-chart which is available via GitHub pages as https://gbaeke.github.io/helm-chart/. When you open that page in the browser, you will see installations instructions.

To add the super api application from the super-api chart repository, first add the repository:

```
helm repo add super-api https://github.com/gbaeke/helm-chart
```

Above, the name `super-api` is arbitrary. You can use any name you like.

Then install the chart: 

```
helm install super super-api/super-api
```

After running the above command, check the installatyion status with the following commands:

```
helm ls

helm list

helm list --all-namespaces

kubectl get deploy

kubectl get pods

kubectl get services

kubectl get hpa
```

To remove the chart (and the application), run the following command:

```
helm uninstall super
```

### Upgrading an installation

Install superapi again with `helm install super super-api/super-api`.

The installation uses version 1.0.3 of the ghcr.io/gbaeke/super image. Let's install a higher version. Because there is no newer chart that installs that version, we will use a parameter to specify the version during the upgrade:

`helm upgrade super super-api/super-api --set image.tag=1.0.4`

If there was a newer version of the chart, we could use:

`helm upgrade super super-api/super-api --version 1.0.1`

Note that 1.0.1 is the **chart version**, not the image version. But that chart version, could use a different image version as default, for instance 1.0.4.

To see the installation history, use `helm history super`. The result could be:

```
REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION
1               Mon Mar 14 18:01:02 2022        superseded      super-api-1.0.0 1.0.3           Install complete
2               Mon Mar 14 18:01:17 2022        deployed        super-api-1.0.0 1.0.3           Upgrade complete
```

Above, there are two revisions. Use `helm get` to obtain information about the revisions:

```
helm get all super --revision=2

helm get manifest super --revision=2

helm get values super --revision=2

helm get values super --revision=1
```

Helm get returns results for the most recent revision. You can set the revision with the `--revision` parameter.

The release information is stored in secrets of type helm.sh/release.v1.

### Rolling back

To roll back to a previous revision, use:

```
helm rollback super 1
```

The command `helm hist super` now shows:

```
REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION
1               Mon Mar 14 18:01:02 2022        superseded      super-api-1.0.0 1.0.3           Install complete
2               Mon Mar 14 18:01:17 2022        superseded      super-api-1.0.0 1.0.3           Upgrade complete
3               Mon Mar 14 18:14:16 2022        deployed        super-api-1.0.0 1.0.3           Rollback to 1
```

Note: when you uninstall a chart, you can keep the history with `helm uninstall super --keep-history`.

### Dry run and template

Use dry run to see what the upgrade would do without actually performing the upgrade:

```
helm upgrade --install super super-api/super-api --set image.tag=1.0.4 --dry-run
```

The output is not YAML you can apply to your cluster because it includes metadata at the top and a NOTES.txt file with instructions.

To obtain a template you can submit to Kubernetes, use the following:

```
helm template super super-api/super-api
```

### Using --wait

To wait until the deployment is ready and healthy, use:

```
helm upgrade --install super super-api/super-api --set image.tag=1.0.4 --wait
```

