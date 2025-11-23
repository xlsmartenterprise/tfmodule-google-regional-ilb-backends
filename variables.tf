variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for the load balancer resources"
  type        = string
}

variable "name" {
  description = "Name for the forwarding rule and prefix for supporting resources."
  type        = string
}

variable "health_check" {
  description = "Health check to determine whether instances are responsive and able to do work"
  type = object({
    type                = string
    check_interval_sec  = optional(number)
    healthy_threshold   = optional(number)
    timeout_sec         = optional(number)
    unhealthy_threshold = optional(number)
    response            = optional(string)
    proxy_header        = optional(string)
    port                = optional(number)
    port_name           = optional(string)
    request             = optional(string)
    request_path        = optional(string)
    host                = optional(string)
    enable_log          = optional(bool)
  })
}

variable "load_balancing_scheme" {
  description = "Load balancing scheme (INTERNAL_MANAGED or EXTERNAL_MANAGED)"
  type        = string
  default     = "INTERNAL_MANAGED"
}

variable "ip_protocol" {
  description = "IP protocol for the forwarding rule (TCP, UDP, ESP, AH, SCTP, or ICMP)"
  type        = string  
}

variable "connection_draining_timeout_sec" {
  description = "Time for which instance will be drained"
  default     = null
  type        = number
}

variable "backends" {
  description = "List of backends, should be a map of key-value pairs for each backend, must have the 'group' key."
  type        = list(any)
}

variable "session_affinity" {
  description = "The session affinity for the backends example: NONE, CLIENT_IP. Default is `NONE`."
  type        = string
  default     = "NONE"
}