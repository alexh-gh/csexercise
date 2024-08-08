resource "google_compute_instance" "gce_instance" {
  name         = "${var.prefix}-gce"
  machine_type = "e2-micro"

  //Define the explicit dependency on the pgsql instance for the custom script
  depends_on = [google_sql_database_instance.pgsql_instance]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network     = google_compute_network.vpc_network.id
    subnetwork  = google_compute_subnetwork.vpc_app_subnet.id

    access_config {
      // Ephemeral public IP
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.gce-sa.email
    scopes = ["cloud-platform"]
  }

  //Simple script to accomplish the ask of setting up an "app" and verify connectivity to the database
  metadata_startup_script = <<EOF
   #! /bin/bash
   apt update
   apt -y install apache2
   apt -y install postgresql-client
   pgReady=$(pg_isready -d csinterview-db -h $"${google_sql_database_instance.pgsql_instance.ip_address.0.ip_address}" -p 5432 -U postgres)
   cat <<EOF > /var/www/html/index.html
   <html><body><p>csexercise app</p></body></html>
   <html><body><p>$pgReady</p></body></html>
   EOF
}