provider "aws" {
  region = "sa-east-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-data-08d51"
    region = "sa-east-1"
    key    = "terraform.tfstate"
  }
}

module "with_cdn" {
  source      = "./with-cdn"
  count       = var.use_cdn == true ? 1 : 0
  domain_name = var.domain_name
  static_dir  = var.static_dir
}

module "without_cdn" {
  source      = "./without-cdn"
  count       = var.use_cdn == false ? 1 : 0
  domain_name = var.domain_name
  static_dir  = var.static_dir
}