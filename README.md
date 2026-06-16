# AKS Terraform — Azure Best Practices

## Arquitectura desplegada

```
Internet
   │
   ▼
[Public IP estática + FQDN]  ←── apunta tu dominio (CNAME / A record)
   │
   ▼
[Application Gateway WAF v2]  (snet-appgw, 3 AZs)
   │  AGIC gestiona dinámicamente backends y rutas
   ▼
[AKS Cluster]  (snet-aks-nodes, 3 AZs)
 ├── System Node Pool (D4ds_v5 × 3–6)
 └── User Node Pool   (D8ds_v5 × 3–12)
      │  Cilium eBPF dataplane + overlay networking
      └── Pods (10.244.0.0/16 — sin consumir IPs del VNet)
```

## Decisiones de diseño

| Área | Decisión | Razón |
|------|----------|-------|
| Network plugin | Azure CNI Overlay | No agota IPs del VNet para pods |
| Dataplane | Cilium eBPF | Mejor rendimiento, NetworkPolicies L7, Hubble |
| Ingress | AGIC + App Gateway WAF v2 | Dominio público, TLS, WAF OWASP integrado |
| Identidad | SystemAssigned + Workload Identity | Sin secrets, seguro, Azure AD nativo |
| Node pools | System separado de User | Estabilidad del plano de control |
| Zonas | 3 availability zones | Alta disponibilidad en cada pool y App Gateway |
| OS Disk | Ephemeral | Sin costo extra, mayor I/O, stateless |

## Requisitos previos

```bash
# Herramientas
terraform >= 1.5.0
az CLI >= 2.55.0

# Login
az login
az account set --subscription "<subscription_id>"

# Feature flags necesarios
az feature register --namespace Microsoft.ContainerService --name AzureOverlayPreview
az feature register --namespace Microsoft.ContainerService --name CiliumDataplane
az provider register -n Microsoft.ContainerService
```

## Deploy

```bash
cp "terraform.tfvars copy.example" terraform.tfvars
# Editar `terraform.tfvars` con tus valores

terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Configurar dominio público

Después del apply, obtienes la IP pública del Application Gateway:

```bash
terraform output appgw_public_ip
# → 20.x.x.x

terraform output appgw_public_ip_fqdn  
# → myapp-prod-ingress.eastus2.cloudapp.azure.com (FQDN automático de Azure)
```

### Opción A — CNAME a FQDN de Azure
```
# En tu proveedor DNS:
api.tudominio.com  CNAME  myapp-prod-ingress.eastus2.cloudapp.azure.com
```

### Opción B — Registro A directo a la IP estática
```
# En tu proveedor DNS:
api.tudominio.com  A  20.x.x.x
```

### Ejemplo de Ingress en Kubernetes con AGIC
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway
    appgw.ingress.kubernetes.io/ssl-redirect: "true"
    # TLS desde Key Vault (requiere Key Vault Secrets Provider add-on)
    appgw.ingress.kubernetes.io/appgw-ssl-certificate: "my-cert-name"
spec:
  rules:
  - host: api.tudominio.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80
  tls:
  - hosts:
    - api.tudominio.com
    secretName: my-tls-secret
```

## Workload Identity (recomendado para pods)

```bash
# Después del apply
# Obtener el OIDC issuer desde el módulo AKS
terraform output -module=aks -raw oidc_issuer_url

# Crear Federated Identity para un SA de Kubernetes
az identity federated-credential create \
  --name my-app-federated \
  --identity-name id-my-app \
  --resource-group rg-myapp-prod-eus2 \
  --issuer $(terraform output -module=aks -raw oidc_issuer_url) \
  --subject system:serviceaccount:default:my-app-sa
```

## Obtener kubeconfig

```bash
$(terraform output -raw get_credentials_command)
kubectl get nodes
```
