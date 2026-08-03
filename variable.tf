variable "RG" {
  type        = string
  description = "Resource Group Name"
  default     = ""
}
variable "location" {
  type        = string
  description = "Location of the Resource Group"
  default     = "eastus"
}
variable "Server_count" {
  type        = number
  description = "Number of Servers to create"
  default     = 2
}
variable "server_name" {
  type        = string
  description = "Name of the Cluster"
  default     = "server"
}
