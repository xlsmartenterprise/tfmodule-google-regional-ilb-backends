# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-23

### Added
- Initial release of the Internal Load Balancer Backend Service module
- Support for creating regional backend services in Google Cloud Platform
- Multiple health check types support: TCP, HTTP, and HTTPS
- Configurable health check parameters:
  - Check interval and timeout settings
  - Healthy and unhealthy thresholds
  - Custom request/response validation
  - Port and port name configuration
  - Proxy header support
  - Optional health check logging
- Backend configuration support:
  - Multiple backends (Instance Groups and Network Endpoint Groups)
  - Balancing mode configuration
  - Capacity scaler settings
  - Per-endpoint and per-instance rate limits
- Connection draining timeout configuration
- Session affinity support (NONE, CLIENT_IP)
- Support for INTERNAL_MANAGED and EXTERNAL_MANAGED load balancing schemes
- Protocol support: TCP, UDP, ESP, AH, SCTP, ICMP

### Outputs
- Backend service ID, self-link, and name
- Health check ID and self-link

### Requirements
- Terraform >= 1.5.0
- Google Provider >= 7.0.0, < 8.0.0
- Google Beta Provider >= 7.0.0, < 8.0.0