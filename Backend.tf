resource "google_compute_backend_service" "website" {
  name        = "my-backend"
  description = "Our company website"
  port_name   = "http"
  protocol    = "HTTP" 
  //port 80
  timeout_sec = 10
  enable_cdn  = false

  backend {
    group = "${google_compute_instance_group_manager.foobar.instance_group}"
  }
   health_checks = ["${google_compute_http_health_check.default.self_link}"]
}
#says its needed for the load balancing of HTTPS/HTTP traffic https://cloud.google.com/compute/docs/instance-groups/


resource "google_compute_http_health_check" "default" {
  name               = "test"
  request_path       = "/"
  check_interval_sec = 5 
  //adjusted to 5 seconds incase there is a glitch in the application as we dont want a new vm being spun up prematurely
  timeout_sec        = 5
  //adjusted to 5 so that the autoscaller waits 5 seconds before considering the request as a failure
  healthy_threshold = 2
  //healthy_threshold, if there is 2 (deafult value) consecutive sucesses then the autoscaler will think 
  //that the VM is healthy so it will continue to monitor
  unhealthy_threshold = 2
  //by default as the unhealthy_threshold is not speficied here then if there is 2 consecutive failures based on the 
  //check interval and the timeout  then it will determine that the VM is unhealthy, then it will start deleting the VM
  //and then create the VM based on the template
}

#https://www.terraform.io/docs/providers/google/r/compute_backend_service.html
//https://cloud.google.com/compute/docs/load-balancing/http/
//HTTP load balancing - requres global forwarding rules?
// - target proxy?
//url map?
//https://cloud.google.com/compute/docs/load-balancing/http/global-forwarding-rules
