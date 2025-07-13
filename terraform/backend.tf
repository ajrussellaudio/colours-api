resource "aws_s3_bucket" "terraform_state" {
  bucket = "colours-api-terraform-state-lock"

  # Enable versioning so we can see the history of our state files
  versioning {
    enabled = true
  }

  # Prevent accidental deletion of this critical resource
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "colours-api-terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
