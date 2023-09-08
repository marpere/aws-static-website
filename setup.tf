provider "aws" {
  region = "sa-east-1"
}

provider "aws" {
  alias  = "n-virginia"
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-data-08d51"
    region = "sa-east-1"
    key    = "terraform.tfstate"
  }
}