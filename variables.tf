# =============================================================================
# variables.tf - Variables globales del proyecto
# =============================================================================

# -----------------------------------------------------------------------------
# Identidad / Suscripción
# -----------------------------------------------------------------------------
variable "subscription_id" {
  description = "ID de la suscripción de Azure"
  type        = string
}

variable "tenant_id" {
  description = "ID del tenant de Azure AD"
  type        = string
}

# -----------------------------------------------------------------------------
# Proyecto y Entorno
# -----------------------------------------------------------------------------
variable "project" {
  description = "Nombre corto del proyecto (usado en nombres de recursos)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{2,12}$", var.project))
    error_message = "El proyecto debe tener entre 2 y 12 caracteres alfanuméricos en minúscula."
  }
}

variable "environment" {
  description = "Entorno de despliegue"
  type        = string
  validation {
    condition     = contains(["dev", "stg", "prod"], var.environment)
    error_message = "El entorno debe ser 'dev', 'stg' o 'prod'."
  }
}

# -----------------------------------------------------------------------------
# Región
# -----------------------------------------------------------------------------
variable "location" {
  description = "Región de Azure"
  type        = string
  default     = "eastus2"
}

variable "location_short" {
  description = "Abreviatura de la región (para nombres de recursos)"
  type        = string
  default     = "eus2"
}

# -----------------------------------------------------------------------------
# Red
# -----------------------------------------------------------------------------
variable "vnet_address_space" {
  description = "Espacio de direcciones del VNet"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "aks_subnet_cidr" {
  description = "CIDR para la subnet de nodos AKS"
  type        = string
  default     = "10.1.0.0/16"
}

variable "aks_pod_cidr" {
  description = "CIDR para pods (Cilium overlay)"
  type        = string
  default     = "10.244.0.0/16"
}

variable "appgw_subnet_cidr" {
  description = "CIDR para Application Gateway (Ingress)"
  type        = string
  default     = "10.2.0.0/24"
}

variable "private_endpoint_subnet_cidr" {
  description = "CIDR para Private Endpoints"
  type        = string
  default     = "10.2.1.0/24"
}

# -----------------------------------------------------------------------------
# AKS - Cluster
# -----------------------------------------------------------------------------
variable "kubernetes_version" {
  description = "Versión de Kubernetes"
  type        = string
  default     = "1.30"
}

variable "availability_zones" {
  description = "Zonas de disponibilidad para el cluster AKS"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "dns_prefix" {
  description = "Prefijo DNS del cluster AKS"
  type        = string
  default     = null
}

variable "private_cluster_enabled" {
  description = "Habilitar cluster privado (API server privado)"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# AKS - System Node Pool
# -----------------------------------------------------------------------------
variable "system_node_pool" {
  description = "Configuración del system node pool"
  type = object({
    name                = string
    vm_size             = string
    min_count           = number
    max_count           = number
    os_disk_size_gb     = number
    os_disk_type        = string
    max_pods            = number
    ultra_ssd_enabled   = bool
  })
  default = {
    name                = "system"
    vm_size             = "Standard_D4ds_v5"
    min_count           = 3
    max_count           = 6
    os_disk_size_gb     = 128
    os_disk_type        = "Managed"  # Mejor rendimiento y menor costo
    max_pods            = 110
    ultra_ssd_enabled   = false
  }
}

# -----------------------------------------------------------------------------
# AKS - User Node Pool (workloads)
# -----------------------------------------------------------------------------
variable "user_node_pool" {
  description = "Configuración del user node pool para workloads"
  type = object({
    name                = string
    vm_size             = string
    min_count           = number
    max_count           = number
    os_disk_size_gb     = number
    os_disk_type        = string
    max_pods            = number
    node_labels         = map(string)
    node_taints         = list(string)
  })
  default = {
    name                = "workload"
    vm_size             = "Standard_D4ds_v6"
    min_count           = 2
    max_count           = 3
    os_disk_size_gb     = 128
    os_disk_type        = "Managed"   # Para workloads, mejor usar disco gestionado
    max_pods            = 110
    node_labels         = { "nodepool-type" = "user" }
    node_taints         = []
  }
}

# -----------------------------------------------------------------------------
# Tags de ciclo de vida (requeridos por muchas políticas Azure)
# -----------------------------------------------------------------------------
variable "owner" {
  description = "Dueño del recurso"
  type        = string
  default     = "platform-team"
}

variable "cost_center" {
  description = "Centro de costos para billing"
  type        = string
  default     = "engineering"
}

variable "aks_admin_group_id" {
  type = string
}