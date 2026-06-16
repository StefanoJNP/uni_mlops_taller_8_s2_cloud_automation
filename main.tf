# =============================================================================
# main.tf - Orquestador principal
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.8.0"
    }
  }

  # ⚠️ Recomendado: usar Azure Blob Storage como backend remoto
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform-state"
  #   storage_account_name = "stterraformstate"
  #   container_name       = "tfstate"
  #   key                  = "aks/terraform.tfstate"
  # }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
  subscription_id = var.subscription_id
}

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project}-${var.environment}-${var.location_short}"
  location = var.location

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Módulo de Red (VNet + Subnets)
# -----------------------------------------------------------------------------
module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  project             = var.project
  environment         = var.environment
  location_short      = var.location_short

  vnet_address_space       = var.vnet_address_space
  aks_subnet_cidr          = var.aks_subnet_cidr
  aks_pod_cidr             = var.aks_pod_cidr
  appgw_subnet_cidr        = var.appgw_subnet_cidr
  private_endpoint_subnet_cidr = var.private_endpoint_subnet_cidr

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Módulo AKS
# -----------------------------------------------------------------------------
module "aks" {
  source = "./modules/aks"

  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  project              = var.project
  environment          = var.environment
  location_short       = var.location_short
  aks_admin_group_id  = var.aks_admin_group_id

  # Red
  vnet_id              = module.networking.vnet_id
  aks_subnet_id        = module.networking.aks_subnet_id
  appgw_subnet_id      = module.networking.appgw_subnet_id

  # Cluster
  kubernetes_version         = var.kubernetes_version
  availability_zones         = var.availability_zones

  # Node pools
  system_node_pool           = var.system_node_pool
  user_node_pool             = var.user_node_pool

  # DNS
  dns_prefix                 = var.dns_prefix
  private_cluster_enabled    = var.private_cluster_enabled

  # Identidad
  tenant_id                  = var.tenant_id

  tags = local.common_tags
}
