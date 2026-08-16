resource "aws_s3_bucket" "terraform_state" {
  bucket = "ecs-v1-gatus-state-s3"

  tags = {
    Name        = "gatus-v1-tfstate"
    Project     = "gatus"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
    bucket = aws_s3_bucket.terraform_state.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
    bucket = aws_s3_bucket.terraform_state.id
     versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_ecr_repository" "gatus" { 
  name = "ecr-gatus-v1"
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Project = "gatus"
  }
}