### helm-charts

This code creates the following set up.

# Ingress-nginx

In Kubernetes, an Ingress is an object that allows access to your Kubernetes services from outside the Kubernetes cluster. You configure access by creating a collection of rules that define which inbound connections reach which services. This lets you consolidate your routing rules into a single resource

Installation process


# Add the ingress-nginx helm repository:
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```

# Install the chart of ingress-nginx
```
helm upgrade --install  ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx
```

### External-DNS

ExternalDNS is a Kubernetes addon that configures public DNS servers with information about exposed Kubernetes services to make them discoverable.

# Add the cert-manager helm repository:
```
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo update
```

# Install external-dns

```
helm upgrade --install  \
  external-dns \
  -n external-dns \
  --set aws.accessKey=$aws_access_key_id \
  --set aws.secretKey=$aws_secret_access_key \
  --set aws.region=$aws_region \
  --set policy=upsert-only \
  --set domainFilters={$ENVIRONMENT.versoview.us} \
  external-dns/external-dns
```


### Cert-manager

cert-manager is a Kubernetes add-on to automate the management and issuance of TLS certificates from various issuing sources.
It will ensure certificates are valid and up to date periodically, and attempt to renew certificates at an appropriate time before expiry.

# Add the cert-manager helm repository:
```
helm repo add jetstack https://charts.jetstack.io
helm repo update
```

# Install the cert-manager chart
```
helm upgrade --install \
   cert-manager jetstack/cert-manager \
   --namespace cert-manager \
   --set installCRDs=true
```


## Grafana emails config 


```
[smtp]
enabled = true
host = smtp.office365.com:587
user = Roman.Pereverziev@alphait.us
password = KnInnOfY21
skip_verify = true
from_address = Roman.Pereverziev@alphait.us
```

```
--set-string alertmanager.config.global.smtp_smarthost="smtp.office365.com:587" \
--set-string alertmanager.config.global.smtp_auth_username="Roman.Pereverziev@alphait.us" \
--set-string alertmanager.config.global.smtp_from="my@email.tld" \
--set-string alertmanager.config.global.smtp_auth_password="MyAmazingPassword" \
--set-string grafana.'grafana\.ini'.smtp.enabled=true \
--set-string grafana.'grafana\.ini'.smtp.host="my.smtp.tld:465" \
--set-string grafana.'grafana\.ini'.smtp.from_address="my@email.tld" \
--set-string grafana.'grafana\.ini'.smtp.user="my@email.tld" \
--set-string grafana.'grafana\.ini'.smtp.password="MyAmazingPassword"
```
https://techexpert.tips/grafana/grafana-email-notification-setup/

https://jorgedelacruz.uk/2019/09/23/grafana-using-microsoft-office-365-for-our-email-notifications/
