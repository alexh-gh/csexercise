resource "google_compute_network" "vpc_network" {
  name                    = "${var.prefix}-vpc"
}

//Setup a private IP address for the database
resource "google_compute_global_address" "pgsql_private_ip_address" {
  provider      = google-beta

  name          = "${var.prefix}-pgsql-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
}

//Assign the pgsql private IP to the VPC
//Need to enable the cloudsourcemanager.googleapi and servicenetworking.googleapi before deploying this
resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = google-beta

  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.pgsql_private_ip_address.name]
}

//Create an application subnet
resource "google_compute_subnetwork" "vpc_app_subnet" {
  name          = "${var.prefix}-app-subnet"
  description   = "Subnet dedicated for the interview application" 
  ip_cidr_range = "10.0.1.0/24"
  region        = var.gcp_region
  network       = google_compute_network.vpc_network.id
}

//Create a firewall policy for the VPC
resource "google_compute_network_firewall_policy" "gce_firewall_policy" {
  name        = "${var.prefix}-gce-firewall-policy"
  description = "GCE network firewall policy"
  project     = var.gcp_project
}

//Create a firewall policy rule for HTTP
resource "google_compute_network_firewall_policy_rule" "gce_firewall_policy_rule_HTTP" {
  action                  = "allow"
  description             = "Allow HTTP/S traffic"
  direction               = "INGRESS"
  disabled                = false
  enable_logging          = true
  firewall_policy         = google_compute_network_firewall_policy.gce_firewall_policy.name
  priority                = 1000
  rule_name               = "http"
  target_service_accounts = [google_service_account.gce-sa.email]

  match {
    src_region_codes          = ["US"]
    src_threat_intelligences  = ["iplist-known-malicious-ips"]

    layer4_configs {
      ip_protocol = "tcp"
      ports       = [ 80,443 ]
    }
  }
}

//Create a firewall policy rule for whitelisted SSH
resource "google_compute_network_firewall_policy_rule" "gce_firewall_policy_rule_SSH" {
  action                  = "allow"
  description             = "Allow Whitelisted SSH"
  direction               = "INGRESS"
  disabled                = false
  enable_logging          = true
  firewall_policy         = google_compute_network_firewall_policy.gce_firewall_policy.name
  priority                = 1100
  rule_name               = "http"
  target_service_accounts = [google_service_account.gce-sa.email]

  match {
    src_threat_intelligences  = ["iplist-known-malicious-ips"]
    src_ip_ranges             = [var.allowedIPs]

    layer4_configs {
      ip_protocol = "tcp"
      ports       = [ 22 ]
    }
  }
}

//Associate the firewall policy with the VPC
resource "google_compute_network_firewall_policy_association" "gce_firewall_vpc_network_association" {
  name              = "${var.prefix}gce-firewall-vpc-association"
  attachment_target = google_compute_network.vpc_network.id
  firewall_policy   =  google_compute_network_firewall_policy.gce_firewall_policy.name
  project           =  var.gcp_project
}