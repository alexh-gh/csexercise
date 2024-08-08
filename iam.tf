resource "google_service_account" "gce-sa" {
  account_id   = "${var.prefix}gce-sa"
  display_name = "Service Account for the gce instance"
}

//IAM policy of users to login to the gce instance via iap
data "google_iam_policy" "gce-iam-admin" {
  binding {
    role = "roles/iap.tunnelResourceAccessor"
    members = [
      for i in local.iam_admins : i
    ]
  }
}

//Need to enable the iap.googleapi and iam.googleapi before deploying this
resource "google_iap_tunnel_instance_iam_policy" "gce-iap-policy" {
  project       = var.gcp_project
  zone          = var.gcp_zone
  instance      = google_compute_instance.gce_instance.name
  policy_data   = data.google_iam_policy.gce-iam-admin.policy_data
}