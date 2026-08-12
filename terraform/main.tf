resource "aws_s3_bucket" "s3" {
  bucket = "ecs-v1-gatus-state-s3"

  tags = {
    Name        = "ecs-v1"
    Project     = "gatus"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
    bucket = aws_s3_bucket.s3.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

