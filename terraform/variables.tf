variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "myResourceGroup"
}

variable "location" {
  description = "Azure region"
  default     = "northeurope"
}

variable "aks_name" {
  description = "Name of the AKS cluster"
  default     = "myAKSCluster"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  default     = "myACRRegistry"
}