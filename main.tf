# Create a Health Check for Backend Service
resource "google_compute_region_health_check" "tcp" {
  provider = google-beta
  count    = var.health_check["type"] == "tcp" ? 1 : 0
  project  = var.project_id
  name     = "${var.name}"
  region   = var.region  

  timeout_sec         = var.health_check["timeout_sec"]
  check_interval_sec  = var.health_check["check_interval_sec"]
  healthy_threshold   = var.health_check["healthy_threshold"]
  unhealthy_threshold = var.health_check["unhealthy_threshold"]

  tcp_health_check {
    port         = var.health_check["port"]
    request      = var.health_check["request"]
    response     = var.health_check["response"]
    port_name    = var.health_check["port_name"]
    proxy_header = var.health_check["proxy_header"]
  }

  dynamic "log_config" {
    for_each = var.health_check["enable_log"] ? [true] : []
    content {
      enable = true
    }
  }
}

resource "google_compute_region_health_check" "http" {
  provider = google-beta
  count    = var.health_check["type"] == "http" ? 1 : 0
  project  = var.project_id
  name     = "${var.name}"
  region   = var.region  

  timeout_sec         = var.health_check["timeout_sec"]
  check_interval_sec  = var.health_check["check_interval_sec"]
  healthy_threshold   = var.health_check["healthy_threshold"]
  unhealthy_threshold = var.health_check["unhealthy_threshold"]

  http_health_check {
    port         = var.health_check["port"]
    request_path = var.health_check["request_path"]
    host         = var.health_check["host"]
    response     = var.health_check["response"]
    port_name    = var.health_check["port_name"]
    proxy_header = var.health_check["proxy_header"]
  }

  dynamic "log_config" {
    for_each = var.health_check["enable_log"] ? [true] : []
    content {
      enable = true
    }
  }
}

resource "google_compute_region_health_check" "https" {
  provider = google-beta
  count    = var.health_check["type"] == "https" ? 1 : 0
  project  = var.project_id
  name     = "${var.name}"
  region   = var.region  

  timeout_sec         = var.health_check["timeout_sec"]
  check_interval_sec  = var.health_check["check_interval_sec"]
  healthy_threshold   = var.health_check["healthy_threshold"]
  unhealthy_threshold = var.health_check["unhealthy_threshold"]

  https_health_check {
    port         = var.health_check["port"]
    request_path = var.health_check["request_path"]
    host         = var.health_check["host"]
    response     = var.health_check["response"]
    port_name    = var.health_check["port_name"]
    proxy_header = var.health_check["proxy_header"]
  }

  dynamic "log_config" {
    for_each = var.health_check["enable_log"] ? [true] : []
    content {
      enable = true
    }
  }
}

resource "google_compute_region_backend_service" "this" {
  project                         = var.project_id
  name                            = var.name
  region                          = var.region
  protocol                        = var.ip_protocol
  load_balancing_scheme           = var.load_balancing_scheme
  connection_draining_timeout_sec = var.connection_draining_timeout_sec
  session_affinity                = var.session_affinity
  
  dynamic "backend" {
    for_each = var.backends
    content {
      balancing_mode = lookup(backend.value, "balancing_mode", null)
      capacity_scaler = lookup(backend.value, "capacity_scaler", null)
      
      max_rate_per_endpoint = can(regex("networkEndpointGroups", backend.value.group)) ? lookup(backend.value, "max_rate_per_endpoint", null) : null
      max_rate_per_instance = can(regex("instanceGroups", backend.value.group)) ? lookup(backend.value, "max_rate_per_instance", null) : null
      
      group = lookup(backend.value, "group", null)
    }
  }
  
  health_checks = concat(
    google_compute_region_health_check.tcp[*].self_link,
    google_compute_region_health_check.http[*].self_link,
    google_compute_region_health_check.https[*].self_link
  )
}