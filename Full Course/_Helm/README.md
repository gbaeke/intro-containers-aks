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

## Creating a chart

Create a chart with `helm create superapi`. This will create a directory with a chart.yaml file, a values.yaml file and a templates directory.

The directory structure is the chart. You can install a chart directly from the file system with:

```
helm install super superapi
```

Above, `superapi` would be the folder containing the chart.yaml file. You can of course use `helm install super .` if you are in that folder.

⚠️ In a pipeline, you can simply install a chart directly from the cloned repository. You do not have to store your Helm chart in a repository.

⚠️ The chart created by `helm create` creates a sample chart that installs nginx.

## Changing Chart.yaml

Below is the chart.yaml file for the superapi chart:

```yaml
apiVersion: v2
name: super-api
version: 1.0.0
description: A Helm chart for super-api

type: application

appVersion: "1.0.3"

keywords:
  - api
  - super-api
  - golang

home: https://github.com/gbaeke/super-api
sources: 
  - https://github.com/gbaeke/super-api

maintainers:
  - name: gbaeke
    email: me@example.com
```

Not all properties are required. The most important properties are:
- apiVersion: Helm 3 uses the v2 API version (Helm 2 used v1)
- name: the name of the chart
- version: the version of the chart; if there are multiple versions in a repository, you can specify the version to install with --version
- appVersion: the version of the application you are installing; the value of appVersion is used by the default `values.yaml` file to determine the tag of the container image
- type: application; the other option is `library` which should be used to provide templates to other application charts; a chart that installs an application in Kubernetes is always an application chart

### Changing values.yaml

The `values.yaml` file is optional. It is used to specify the values for the chart. Those values are used in templates to render the final YAML that the chart will install.

In the sample values.yaml, you will see the following first 5 lines:

```yaml
# Default values for super-api.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

replicaCount: 1
```

Above, the value of `replicaCount` is 1. It is used in the `deployment.yaml` template to create a deployment with 1 replica. The `deployment.yaml` file is in the `templates` directory. `replicaCount` is referenced as follow:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "super-api.fullname" . }}
  labels:
    {{- include "super-api.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
```

Above, {{.Values.replicaCount}} will be replaced by `1` when you run `helm install install-name chart-name`. Helm uses the Go template syntax.

In values.yaml, make the following changes:
- set replicaCount to 2
- set image.repository to ghcr.io/gbaeke/super
- remove {} behind `securityContext` and uncomment the commented YAML under it
- do the same for `resources`
- enable `autoscaling` (enabled: true) and set min and max replicas to 1 and 5 respectively

In `deployment.yaml`, make the following changes:
- set `containerPort` to 8080 (there is no value for it in the sample)
- livenessProbe should use /healthz endpoint
- readinessProbe should use /readyz endpoint

**Note**: instead of modifying the containerPort value, you could add a value for it in values.yaml and reference it in the deployment.yaml.

### Running `helm template`

Run `helm template .` from the folder that contains the chagrt to see the template that will be used to install the chart. Does it render well? Make an error in deployment.yaml and try again.

### Using dry-run

The `helm template` command does not contact the Kubernetes API server. When you do a dry run, the Kubernetes API server is contacted. We can check this by adding the following line to Chart.yaml:

```
kubeVersion: ">= 1.23.0"
```

Now run `helm install super . --dry-run`. This should fail with the following warning if you are **NOT** running Kubernetes 1.23 or later:

```
Error: INSTALLATION FAILED: chart requires kubeVersion: >= 1.23.0 which is incompatible with Kubernetes v1.21.9
```

## Templating

### Templates

Templates are in the `templates` directory. This is a convention, not a requirement. Below is an example of a template:

```
plane: {{ .Values.plane | default "Airbus" | quote }}  
```

This is similar to a Linux pipeline:
- grab the plane value from the values.yaml file
- when there is not value, set it to "Airbus"
- quote the value (put "" around the value)

### Named templates

You can define and name templates to reuse them in other templates. For example, `deployment.yaml` begins with the following:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "super-api.fullname" . }}
  labels:
    {{- include "super-api.labels" . | nindent 4 }}
```

In metadate, the name field is a template that references another template called `super-api.fullname`. In this case, the `super-api.fullname` template is defined in `_helpers.tpl`. It is defined as follows:

```yaml
{{- define "super-api.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}
```

What this does exactly is not too important. The template uses many of the Golang templating features such as if statements, variables, and so on.

### Using data from values.yaml and Chart.yaml

To grab data from these files, use `.Values.XYZ` or `.Chart.XYZ`. An example would be:
- {{ .Values.image.repository }}
- {{ .Chart.AppVersion }}

In `deployment.yaml`, the `image.repository` field is a template that references `.Values.image.repository`:

```yaml
image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
```

The references to Values and Chart start with a . (dot). This . (dot) object is passed by Helm to your templates. The dot object contains:
- Values: the values.yaml file (.Values.someKeyYouChoose)
- Chart: the Chart.yaml file (.Chart.Name, .Chart.Version, ...)
- Release: release information like .Release.Name
- Capabilities: used to query the Kubernetes API server for capabilities such as .Capabilities.KubeVersion.Major
- Files: work with files in your template

### Conditional logic

Simple `if` statement:

```yaml
{{- if not .Values.autoscaling.enabled }}
replicas: {{ .Values.replicaCount }}
{{- end }}
```

Use `with` to do the same but also replace the . object:

```yaml
    {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
    {{- end }}
```

Above you check if .Values.podAnnotations is defined and if so, print it as YAML. The . object now only contains the podAnnotations, not the entire . object. It is necessary to convert . to YAML with the toYaml function and indent the YAML properly!

