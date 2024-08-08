//UPDATEME
variable "gcp_project" {
  type          = string
  default       = "virtual-dynamo-000000-s0"
  description   = "The Google Cloud Platform Project ID to deploy resources to"
}

variable "gcp_region" {
  type          = string
  default       = "us-central1"
  description   = "The Google Cloud Platform Region to deploy resources to"
}

variable "gcp_zone" {
  type          = string
  default       = "us-central1-a"
  description   = "The Google Cloud Platform Zone to deploy resources to"
}

variable "prefix" {
    type        = string
    default     = "csexercise"
    description = "The prefix to be used in the naming convention of resources"
}

//UPDATEME
locals {
  iam_admins = [
    "serviceAccount:${google_service_account.gce-sa.email}",
    "user:example@gmail.com"
  ]
}

//UPDATEME
//This variable should be populated with a public IP address to access the application server, such as an office public ip. Default is set to 000 to ensure this is updated.
variable "allowedIPs" {
  type          = string
  default       = "000.000.000.000"
  description   = "The external public IP address to access internal resources from"
}