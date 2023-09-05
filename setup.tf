provider "aws" {
  region = "sa-east-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-data-${var.app_name}"
    region = "sa-east-1"
    key    = "terraform.tfstate"
  }
}