
resource "google_compute_global_forwarding_rule" "default" {
  name       = "default-rule"
  target     = "${google_compute_target_https_proxy.default.self_link}"
  port_range = "443"
  ip_address = "ipaddr1"
//  ip_address = "${google_compute_global_address.default.address}"
//the above code is fine the problem  is that the static IP needs to be computed 1st 
//so that we can use it to build certs as the ip addresses are substuted for the CN .. ie the common name
}

//ip_address - (Optional) The static IP. (if not set, an ephemeral IP is used
//inother words it should make an ip address for us as its set to ephemeral but this would not work with the
//ssl certificates reason being becuase with a static we can gthen define the common name and upload it 
//remeber without a domain name we cannot get a green ssl as the origin server is not directly reachable, becuase
//we are using 1 global Ip for  both instances it also mentions in the docs
//Note: SSL certificate resources are not used on individual VM instances. On an instance, install the normal SSL certificate as described in your application documentation. SSL certificate resources are used only with load balancing proxies such as a target HTTPS proxy or target SSL proxy. See that documentation for when and how to use SSL certificate resources.
//https://www.terraform.io/docs/providers/google/r/compute_global_forwarding_rule.html

//creates a Global static  IP Address
//resource "google_compute_global_address" "default" {
//  name = "test-global-address"
//}

resource "google_compute_target_https_proxy" "default" {
  name             = "test-proxy"
  description      = "a description"
  url_map          = "${google_compute_url_map.default.self_link}"
  ssl_certificates = ["${google_compute_ssl_certificate.default.self_link}"]
}

resource "google_compute_ssl_certificate" "default" {
  name        = "my-certificate"
  description = "a description"
  private_key = "${file("ssl_cert/private.key")}"
  certificate = "${file("ssl_cert/certificate.crt")}"
}

//https://cloud.google.com/compute/docs/load-balancing/http/ssl-certificates

resource "google_compute_url_map" "default" {
  name            = "url-map"
  description     = "a description"
  default_service = "${google_compute_backend_service.default.self_link}"

//  host_rule {
//    hosts        = ["mysite.com"]
//    path_matcher = "allpaths"
//  }

//  path_matcher {
//    name            = "allpaths"
//    default_service = "${google_compute_backend_service.default.self_link}"

//    path_rule {
//      paths   = ["/*"]
//      service = "${google_compute_backend_service.default.self_link}"
//    }

//dont think the code abovde is needed becuase
//we do not have a DNS hostname or need to direct data to a spefic folder but on top of this a new URL Map will deafult to (/*) automatically upon creation
  }
//}

//Back end configuration
resource "google_compute_backend_service" "default" {
  name        = "default-backend"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10
  enable_cdn  = false

    backend {
    group = "${google_compute_instance_group_manager.foobar.instance_group}"
  }
  health_checks = ["${google_compute_http_health_check.default.self_link}"]
}

resource "google_compute_http_health_check" "default" {
  name               = "test"
  request_path       = "/"
  check_interval_sec = 5
  timeout_sec        = 5
  healthy_threshold = 2
  unhealthy_threshold = 2
}

resource "google_compute_target_pool" "foobar" {
  name = "foobar"
}

resource "google_compute_instance_group_manager" "foobar" {
  name = "foobar"
  zone = "${var.region_zone}"

  instance_template  = "${google_compute_instance_template.foobar.self_link}"
  target_pools       = ["${google_compute_target_pool.foobar.self_link}"]
  base_instance_name = "foobar"
}



//https://www.terraform.io/docs/providers/google/r/compute_global_forwarding_rule.html
//https://www.terraform.io/docs/providers/google/r/compute_target_https_proxy.html
//usefull IAM stuff https://www.youtube.com/watch?v=96HlT4f2AUU


//security https://cloud.google.com/compute/docs/load-balancing/ssl-policies#KI
//google explains that currently as there is no SSL policy set for the curerent configuration
//the following ciphers are allowed on the load balancer
//TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256
//TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384
//TLS_RSA_WITH_AES_128_CBC_SHA256
//TLS_RSA_WITH_AES_256_CBC_SHA256
//However google is deprecating support for theese ciphers on both the SSL proxy and the HTTPS load balancer
//so may be worth checking current cipher support and adding a profile if needed
//other note All of the features control whether particular cipher suites can be used, and apply only to client connections using TLS version 1.2 or earlier, not to clients using QUIC.
//note: If your policy selects the CUSTOM profile, however, you must modify the policy’s settings in order to use added features.

