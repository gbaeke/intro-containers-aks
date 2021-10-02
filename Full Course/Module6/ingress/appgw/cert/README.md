# Generate CA private key

openssl genrsa -out ca.key 2048

# Generate self-signed certificate

```language=sh
openssl req -x509 \
  -new -nodes  \
  -days 365 \
  -key ca.key \
  -out ca.crt \
  -subj "/CN=app.20.86.206.159.nip.io"
```

**Note:** used common name as defined in ingress (name resolves to public IP of Azure Application Gateway)

# Create secret containing the certificate

```language=sh
kubectl create secret tls appgw-cert \
--key ca.key \
--cert ca.crt
```

**Note:** use secret in ingress
