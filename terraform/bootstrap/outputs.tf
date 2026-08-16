output "terraform_state_bucket" {
  description = "name of the s3 bucket used for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "ecr_repository_url" {
  description = "url of the ecr repo used for app images"
  value       = aws_ecr_repository.gatus.repository_url
}
