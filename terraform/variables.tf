variable "subscription_id" {
  description = "StagingCSP subscription ID."
  type        = string

  validation {
    condition     = var.subscription_id == "0c4be6f5-0bcc-42f0-af63-8c23938dcd59"
    error_message = "This project may only target the StagingCSP subscription."
  }
}

variable "location" {
  description = "Azure region for all lab resources."
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Resource group owned by the learning project."
  type        = string
  default     = "rg-kristian-devops-lab"
}

variable "owner" {
  description = "Owner tag applied to Azure resources."
  type        = string
  default     = "kristian"
}