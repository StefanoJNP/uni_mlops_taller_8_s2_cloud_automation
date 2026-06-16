# =============================================================================
# modules/networking/variables.tf
# =============================================================================

variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "project"             { type = string }
variable "environment"         { type = string }
variable "location_short"      { type = string }
variable "vnet_address_space"  { type = list(string) }
variable "aks_subnet_cidr"     { type = string }
variable "aks_pod_cidr"        { type = string }
variable "appgw_subnet_cidr"   { type = string }
variable "private_endpoint_subnet_cidr" { type = string }
variable "tags"                { type = map(string) }
