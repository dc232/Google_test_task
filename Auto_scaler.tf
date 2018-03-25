resource "google_compute_autoscaler" "foobar" {
  name   = "scaler"
  zone   = "${var.region_zone}"
  target = "${google_compute_instance_group_manager.foobar.self_link}"

  autoscaling_policy = {
    max_replicas    = 2
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.4
    }
  }
}