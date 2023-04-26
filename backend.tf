terraform {
  backend "s3" {
    bucket = "terraform-default-backend"
    region = "sa-east-1"
    key    = "terraform.tfstate"
  }
}