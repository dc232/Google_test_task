//static IP addrress reservation for the loadbalancer to be attached in the VPC

//resource "google_compute_address" "default" {
//  name = "test-address"
//}

//found from https://www.terraform.io/docs/providers/google/r/compute_address.html
//GCP docs https://cloud.google.com/compute/docs/instances-and-network


//by default a IPV4 exsternal address is computed and given but not assighned to a project
//ie the IPV4 address is not in use just reserved
//should be noted that if the IPV4 address is not in use we will be charged


//The problem witht he code above is that it provisions a static Ip address in a set region and thus it cannot be used 
//to create a global ip address which is needed to set up forwarding rules for the creation of the loadbalancer
//therefore the new code below should work 


 resource "google_compute_global_address" "default" {
  name = "test-global-address"
}

//the code above was found via https://www.terraform.io/docs/providers/google/r/compute_global_address.html
//ofcourse this means that we are only lmited to 1 global Ip address so we must check that one is not in use thogh the command 
//gcloud compute addresses list in gcloud
