//firewall rules definition

// resource "google_compute_firewall" "default" {
//  name    = "test-firewall"
//  network = "${google_compute_network.other.name}"

//  allow {
//    protocol = "icmp"
//  }

//  allow {
//    protocol = "tcp"
//    ports    = ["80", "8080", "1000-2000"]
//  }

//  source_tags = ["http-tag"]
//}


//https://www.terraform.io/docs/providers/google/r/compute_firewall.html

//resource "google_compute_forwarding_rule" "default" {
//  name       = "website-forwarding-rule"
//  target     = "${google_compute_target_pool.foobar.self_link}"
//  port_range = "80"
//}

#https://github.com/tasdikrahman/terraform-google-network-firewall
//example