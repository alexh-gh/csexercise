resource "random_id" "db_name_suffix" {
  byte_length = 4
}

//Need to enable the sqladmin.googleapi before deploying this
resource "google_sql_database_instance" "pgsql_instance" {
  name             = "${var.prefix}-pgsql-instance-${random_id.db_name_suffix.hex}"
  region           = var.gcp_region
  database_version = "POSTGRES_15"

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.vpc_network.self_link
      enable_private_path_for_google_cloud_services = true
    }
    
    backup_configuration {
      enabled = true
    }
  }
}

resource "google_sql_database" "pgsql_database" {
  name     = "${var.prefix}-db"
  instance = google_sql_database_instance.pgsql_instance.name
}