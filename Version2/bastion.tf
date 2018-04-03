resource "google_compute_instance" "default" {
  name         = "bastion-host"
  machine_type = "f1-micro"
  zone         = "us-central1-a"

  tags = ["http-custom-rule", "ssh-custom-rule"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1604-lts"
    }
  }

  // Local SSD disk
  scratch_disk {
  }

  network_interface {
    network = "custom"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    foo = "bar"
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

//demo https://codelabs.developers.google.com/codelabs/gcp-infra-bastion-host/index.html?index=..%2F..%2Fcloud#1