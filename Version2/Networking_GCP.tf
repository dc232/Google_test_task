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
  network       = "${google_compute_network.default.self_link}"
  region        = "us-central1"
}

resource "google_compute_network" "default" {
  name = "custom"
}