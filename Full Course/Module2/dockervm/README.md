# Deploy VM with Docker in Azure

```bash
az deployment sub create --template-file main.bicep --location westeurope
```

After deployment, SSH into the VM with user **azureuser** and the password you chose.

Verify you can run **sudo docker ps** without errors. If you want to run docker without sudo, use the following command:

```
sudo usermod -aG docker azureuser
```

Verify you can run **kind** without errors.

