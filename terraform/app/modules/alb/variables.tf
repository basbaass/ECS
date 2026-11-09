variable "public_subnets_ids" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "prefix" {
  type    = string
  default = "status"
}
