provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_firewall" "allow_health_check_and_proxy" {
  name    = "fw-allow-health-check-and-proxy"
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = ["9376"]
  }

  direction = "INGRESS"
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16",
  ]

  target_tags = var.gke_node_network_tags
}

resource "google_compute_global_address" "hostname_server_vip" {
  name       = "hostname-server-vip"
  ip_version = "IPV4"
}

resource "google_compute_health_check" "http_basic_check" {
  name = "http-basic-check"
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

resource "google_compute_backend_service" "my_bes" {
  name                  = "my-bes"
  protocol              = "HTTP"
  health_checks         = [google_compute_health_check.http_basic_check.id]
  load_balancing_scheme = "EXTERNAL"
}

resource "google_compute_url_map" "web_map" {
  name            = "web-map"
  default_service = google_compute_backend_service.my_bes.id
}

resource "google_compute_target_http_proxy" "http_lb_proxy" {
  name    = "http-lb-proxy"
  url_map = google_compute_url_map.web_map.id
}

resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name       = "http-forwarding-rule"
  ip_address = google_compute_global_address.hostname_server_vip.address
  target     = google_compute_target_http_proxy.http_lb_proxy.id
  port_range = "80"
}

resource "google_compute_network_endpoint_group" "neg" {
  name                  = var.neg_name
  zone                  = var.neg_zone
  network               = var.network_name
  default_port          = 80
  network_endpoint_type = "GCE_VM_IP_PORT"
}

resource "google_compute_network_endpoint" "neg_endpoint" {
  count = var.neg_instance_count

  network_endpoint_group = google_compute_network_endpoint_group.neg.id
  instance               = element(var.neg_instance_names, count.index)
  ip_address             = element(var.neg_instance_ips, count.index)
  port                   = 80
  zone                   = var.neg_zone
}

resource "google_compute_backend_service" "my_bes_backend" {
  name          = google_compute_backend_service.my_bes.name
  protocol      = google_compute_backend_service.my_bes.protocol
  health_checks = google_compute_backend_service.my_bes.health_checks

  backend {
    group                 = google_compute_network_endpoint_group.neg.id
    balancing_mode        = "RATE"
    max_rate_per_endpoint = 5
  }
}