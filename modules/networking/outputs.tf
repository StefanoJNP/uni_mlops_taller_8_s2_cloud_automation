# =============================================================================
# modules/networking/outputs.tf
# =============================================================================

output "vnet_id"   { value = azurerm_virtual_network.main.id }
output "vnet_name" { value = azurerm_virtual_network.main.name }

output "aks_subnet_id"          { value = azurerm_subnet.aks_nodes.id }
output "appgw_subnet_id"        { value = azurerm_subnet.appgw.id }
output "private_endpoint_subnet_id" { value = azurerm_subnet.private_endpoints.id }

output "log_analytics_workspace_id" { value = azurerm_log_analytics_workspace.main.id }
