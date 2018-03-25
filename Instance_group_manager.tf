//resource "google_compute_target_pool" "foobar" {
//  name = "foobar"
//}

//resource "google_compute_instance_group_manager" "foobar" {
//  name = "foobar"
//  zone = "us-central1-f"

//  instance_template  = "${google_compute_instance_template.foobar.self_link}"
//  target_pools       = ["${google_compute_target_pool.foobar.self_link}"]
//  base_instance_name = "foobar"
//}