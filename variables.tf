variable "app_name" {
  description = "Name of the app to name the bucket and the cf distribution"
  type        = string
  default     = "301234d01"
}

variable "static_dir" {
  description = "Directory of the static files to be upload to s3"
  type        = string
  default     = "./public/"
}