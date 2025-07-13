terraform {
  backend "s3" {
    bucket         = "colours-api-terraform-state-lock"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "colours-api-terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-west-1"
}
