provider "google" {
  project       = var.gcp_project
  region        = var.gcp_region
  zone          = var.gcp_zone

  add_terraform_attribution_label   = true
  terraform_attribution_label_addition_strategy = "PROACTIVE"
}

provider "google-beta" {
  project       = var.gcp_project
  region        = var.gcp_region
  zone          = var.gcp_zone

  add_terraform_attribution_label   = true
  terraform_attribution_label_addition_strategy = "PROACTIVE"
}

provider "random" {
}