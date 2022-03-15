# Authenticate

Login with current Azure AD user to registry gebareg.azurecr.io:

```yaml
ACR_NAME=gebareg
USER_NAME="00000000-0000-0000-0000-000000000000"
PASSWORD=$(az acr login --name $ACR_NAME --expose-token --output tsv --query accessToken)
```

The password is the Azure AD token.

Login to the registry with Helm:

```
helm registry login $ACR_NAME.azurecr.io \
  --username $USER_NAME \
  --password $PASSWORD
```

Push the helm chart to the registry:

```
helm push Full Course/_Helm/super-api-1.0.0.tgz oci://$ACR_NAME.azurecr.io/helm
```

Show repos:

```
az acr repository show \
  --name $ACR_NAME \
  --repository helm/super-api
```

Show manifests:

```
az acr repository show-manifests \
  --name $ACR_NAME \
  --repository helm/super-api --detail
```

Install from repo:

```
helm install --dry-run supertest oci://$ACR_NAME.azurecr.io/helm/super-api --version 1.0.0
```