variable "amis" {
  type = map

  default = {
      "us-east-1" = "ami-07ebfd5b3428b6f4d"
      
  }
}

variable "cdir_acesso_remoto" {
  type = list
  default = ["179.235.96.178/32","192.32.154.79/32"]
}

variable "key_name" {
  default = "id_bionic"  
}
