resource "google_compute_subnetwork" "custom-us-central1" {
  name          = "custom-us-central1"
  ip_cidr_range = "10.0.0.0/28"
  // updated CUDR range as to reflect documentation https://cloud.google.com/vpc/docs/vpc#subnet-ranges
  //minimum range is /29 meaning that in legacy netorking there are 6 IPs that can be used
  // 1 for the Network address and the other is broadcast
  // In the case  if GCP 4 of the address are reserved 
  //These are 
  //Network
  //Default Gateway
  //Second-to-last Reservation
  //Broadcast
  // Therefore we need 3 + 4 = 7 IPs total (1 for bastion and 2 for the hosts in the subnet)
  //28 should be used in this case as theere are (2^32 - 2^28) = 2^4 = 16 address total 
  // I will see the possibility of VPC peering soon if possible to create 2 subnets 1 public and 1 private 
  //for now I will check via a deafult gateway for internet acess
  network       = "${google_compute_network.default.self_link}"
  region        = "us-central1"
}

resource "google_compute_network" "default" {
  name = "custom"
}



resource "google_compute_firewall" "icmp" {
  name    = "ICMP-custom-rule"
  network = "${google_compute_network.default.name}"

  allow {
    protocol = "icmp"
  }
//Added firewall rules to allow both ICMP
//source tag in this case is seen as filters
  source_tags = ["icmp-rule"]
}

resource "google_compute_firewall" "http" {
  name    = "HTTP-custom-rule"
  network = "${google_compute_network.default.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }
//Added firewall rules to allow HTTP

//source tag in this case is seen as filters
  source_tags = ["web-rule"]
}


resource "google_compute_firewall" "https" {
  name    = "HTTP-custom-rule"
  network = "${google_compute_network.default.name}"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
//Added firewall rules to allow HTTP

//source tag in this case is seen as filters
  source_tags = ["https-rule"]
}

resource "google_compute_firewall" "ssh" {
  name    = "SSH-custom-rule"
  network = "${google_compute_network.default.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
//Added firewall rules to allow SSH

//source tag in this case is seen as filters
  source_tags = ["ssh-rule"]
}

//creates firewall rule needed to allow traffic through to the network
//by deafult there is an implict deny on all traffic toward the newly created network 
//therefore we need to add rules 
//https://cloud.google.com/compute/docs/networks-and-firewalls