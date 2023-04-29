provider "aws" {
  region = "sa-east-1"
}

terraform {
  backend "s3" {
    bucket = "1d54sce4e4c15"
    region = "sa-east-1"
    key    = "terraform.tfstate"
  }
}