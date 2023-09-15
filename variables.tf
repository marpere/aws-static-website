variable "static_dir" {
  description = "Directory of the static files to be upload to s3"
  type        = string
  default     = "./public/"
}

variable "domain_name" {
  description = "Domain name that the static site will be serverd"
  type        = string
  default     = "example.com.br"
}

variable "use_cdn" {
  description = "Is gonna use cdn"
  type        = bool
  default     = false
}