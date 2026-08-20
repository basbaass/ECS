terraform {
  backend "s3" {
    bucket       = "ecs-v1-gatus-state-s3"
    key          = "app/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}