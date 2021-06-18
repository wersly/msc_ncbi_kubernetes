variable "vpc_cidr" {
  type = string
}

variable "vpc_azs" {
  type = list
}

variable "vpc_public_subnets" {
  type = list
}

variable "eks_map_users" {
  type = list
}

variable "eks_map_accounts" {
  type = list
}
