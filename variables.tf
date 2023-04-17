variable "host_os" {
  type = string
}

variable "personal_ip" {
  type    = string
  default = "*" #Replace the * with your public IP so that only you can access your VM
}

variable "resource_group" {
  type    = string
  default = "" #Enter a unique name for your resource group !It won't work if it isn't unique!
}