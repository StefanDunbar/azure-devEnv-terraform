variable "host_os" {
  type = string
}

variable "personal_ip" {
  type    = string
  default = "*" #Make sure the replace the * with your public IP so that only you can access your VM
}