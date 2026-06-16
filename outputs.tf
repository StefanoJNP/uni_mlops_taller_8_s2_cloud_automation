# =============================================================================
# outputs.tf - Outputs del módulo raíz
# =============================================================================

output "resource_group_name" {
  description = "Nombre del Resource Group principal"
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "ID del Virtual Network"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Nombre del Virtual Network"
  value       = module.networking.vnet_name
}

output "aks_subnet_id" {
  description = "ID de la subnet de nodos AKS"
  value       = module.networking.aks_subnet_id
}

output "aks_cluster_id" {
  description = "ID del cluster AKS"
  value       = module.aks.cluster_id
}

output "aks_cluster_name" {
  description = "Nombre del cluster AKS"
  value       = module.aks.cluster_name
}

output "aks_fqdn" {
  description = "FQDN del API server del cluster AKS"
  value       = module.aks.cluster_fqdn
}

output "aks_identity_principal_id" {
  description = "Principal ID de la identidad gestionada del cluster AKS"
  value       = module.aks.kubelet_identity_principal_id
}

output "appgw_public_ip" {
  description = "IP pública del Application Gateway (Ingress)"
  value       = module.aks.appgw_public_ip
}

output "appgw_public_ip_fqdn" {
  description = "FQDN de la IP pública del Application Gateway"
  value       = module.aks.appgw_public_ip_fqdn
}

# Comando para obtener las credenciales del cluster
output "get_credentials_command" {
  description = "Comando para obtener kubeconfig del cluster"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${module.aks.cluster_name} --overwrite-existing"
}
