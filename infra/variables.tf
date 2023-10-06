variable "region" {
  type    = string
  default = "us-east-1"
}

variable "prefix" {
  default = ""
  type    = string
}

variable "create_services_on_localstack" {
  type    = bool
  default = false
}