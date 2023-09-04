variable "app_name" {
  description = "Name of the app to name the bucket"
  type = string
  default = "301234d01"
}

variable "static_dir" {
  description = "Directory of the static files"
  type = string
  default = ".public/"
}