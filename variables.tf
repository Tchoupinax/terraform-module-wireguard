variable "server_ssh_ip" {
  description = "The reachable ip on which wireguard's server will be installed."
  type        = string
}

variable "server_ssh_user" {
  description = "The user to use to access the server via SSH."
  type        = string
  default     = "root"
}

variable "server_ssh_private_key" {
  description = "The private ssh key to use to access the server via SSH."
  type        = string
}

variable "depends_on_" {
  description = "Resource dependency of this module."
  type        = list(any)
  default     = null
}

variable "clients_count" {
  description = "Provide the number of client you want."
  type        = number
  default     = 1
}

variable "clients_name" {
  description = "Provide the name you want for your clients."
  type        = list(string)
  default     = null
}

variable "CIDR" {
  description = "Provide the network to use for the VPN."
  type        = string
  default     = "10.42.42.42/0"
}
