resource "google_compute_instance_template" "foobar" {
  name        = "appserver-template"
  description = "This template is used to create app server instances."

  tags = ["http-server", "bar"]

//specifying http-tag says that port 80 traffic wull be allowed to communictate with the VM 
//the tags above correlate to network tags in the instance template

  labels = {
    environment = "dev"
  }

  instance_description = "description assigned to instances"
  machine_type         = "f1-micro"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    source_image = "ubuntu-os-cloud/ubuntu-1604-lts"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }


  metadata {
    foo = "bar"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}