variable "public_subnets_ids" {
  type = list(string)
}

variable "alb_sg_ids" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "domain_name" {
  type = string
}
