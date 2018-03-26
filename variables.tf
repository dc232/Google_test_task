variable "region" {
  default = "us-central1"
}

variable "region_zone" {
  default = "us-central1-f"
}

variable "project_name" {
  description = "Name of the project otherwise known as project ID"
  default = "smart-radio-198517"
}

variable "public_key_path" {
  description = "Path to file containing public key"
  default = "vm_instance_keypair/gcloud_instance_key.pub"
}