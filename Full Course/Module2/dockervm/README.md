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


# Install k9s

Run `brew`, enter your password and follow the instructions.

When finished, run these commands:

```
test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
test -r ~/.bash_profile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bash_profile
echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.profile
```

Exit the shell and SSH back in the VM. 

Install k9s with `brew install k9s`. After installation, you should be able to run `k9s` without errors.

# Install krew

Install krew by running the following commands:

```
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
```

Add the following line to `.bashrc` (from your home directory):

```
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
```

Run `source .bashrc` to reload the new PATH.

Install ctx and ns extensions:

```
kubectl krew install ctx
kubectl krew install ns
```

Now run `kubectl ctx` and `kubectl ns` without errors. With ctx you can easily switch between contexts. With ns you can easily switch between namespaces.

