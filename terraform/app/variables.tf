variable "region" {
    description = "AWS region to deploy to"
    type = string
}

variable "availability_zones" {
  description = "Availability zones for app"
  type = list(string)
}