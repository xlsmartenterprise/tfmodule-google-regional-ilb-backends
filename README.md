# tfmodule-google-ilb-backends

A Terraform module for creating and managing Internal Load Balancer (ILB) Backend Services on Google Cloud Platform. This module simplifies the creation of regional backend services with configurable health checks and backend configurations.

## Features

- **Multiple Health Check Types**: Support for TCP, HTTP, and HTTPS health checks
- **Flexible Backend Configuration**: Works with both Instance Groups and Network Endpoint Groups (NEGs)
- **Advanced Health Check Options**: Configurable intervals, thresholds, logging, and custom validation
- **Load Balancing Control**: Support for different balancing modes and capacity scaling
- **Session Affinity**: Configurable session affinity options (NONE, CLIENT_IP)
- **Connection Draining**: Graceful connection draining with configurable timeout
- **Regional Resources**: All resources are region-scoped for improved latency and availability

## Usage

### Basic Example with TCP Health Check

```hcl
module "ilb_backend" {
  source = "github.com/your-org/tfmodule-google-ilb-backends?ref=v1.0.0"

  project_id  = "my-gcp-project"
  region      = "us-central1"
  name        = "my-backend-service"
  ip_protocol = "TCP"

  health_check = {
    type                = "tcp"
    port                = 80
    check_interval_sec  = 5
    timeout_sec         = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    enable_log          = false
  }

  backends = [
    {
      group           = "https://www.googleapis.com/compute/v1/projects/my-project/zones/us-central1-a/instanceGroups/my-instance-group"
      balancing_mode  = "CONNECTION"
      capacity_scaler = 1.0
    }
  ]
}
```

### HTTP Health Check with Multiple Backends

```hcl
module "ilb_backend_http" {
  source = "github.com/your-org/tfmodule-google-ilb-backends?ref=v1.0.0"

  project_id  = "my-gcp-project"
  region      = "us-central1"
  name        = "web-backend-service"
  ip_protocol = "TCP"

  health_check = {
    type                = "http"
    port                = 80
    request_path        = "/health"
    check_interval_sec  = 10
    timeout_sec         = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    enable_log          = true
  }

  session_affinity                = "CLIENT_IP"
  connection_draining_timeout_sec = 300

  backends = [
    {
      group                 = "https://www.googleapis.com/compute/v1/projects/my-project/zones/us-central1-a/instanceGroups/backend-1"
      balancing_mode        = "RATE"
      max_rate_per_instance = 100
      capacity_scaler       = 1.0
    },
    {
      group                 = "https://www.googleapis.com/compute/v1/projects/my-project/zones/us-central1-b/instanceGroups/backend-2"
      balancing_mode        = "RATE"
      max_rate_per_instance = 100
      capacity_scaler       = 0.8
    }
  ]
}
```

### HTTPS Health Check with Network Endpoint Group

```hcl
module "ilb_backend_https" {
  source = "github.com/your-org/tfmodule-google-ilb-backends?ref=v1.0.0"

  project_id  = "my-gcp-project"
  region      = "europe-west1"
  name        = "secure-backend-service"
  ip_protocol = "TCP"

  health_check = {
    type                = "https"
    port                = 443
    request_path        = "/api/health"
    host                = "api.example.com"
    check_interval_sec  = 15
    timeout_sec         = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    proxy_header        = "NONE"
    enable_log          = true
  }

  backends = [
    {
      group                 = "https://www.googleapis.com/compute/v1/projects/my-project/regions/europe-west1/networkEndpointGroups/my-neg"
      balancing_mode        = "RATE"
      max_rate_per_endpoint = 50
      capacity_scaler       = 1.0
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | The GCP project ID | `string` | n/a | yes |
| region | The GCP region for the load balancer resources | `string` | n/a | yes |
| name | Name for the backend service and health check | `string` | n/a | yes |
| ip_protocol | IP protocol for the backend service (TCP, UDP, ESP, AH, SCTP, or ICMP) | `string` | n/a | yes |
| health_check | Health check configuration object | `object` | n/a | yes |
| backends | List of backend configurations | `list(any)` | n/a | yes |
| load_balancing_scheme | Load balancing scheme (INTERNAL_MANAGED or EXTERNAL_MANAGED) | `string` | `"INTERNAL_MANAGED"` | no |
| connection_draining_timeout_sec | Time in seconds for instance draining | `number` | `null` | no |
| session_affinity | Session affinity for backends (NONE, CLIENT_IP) | `string` | `"NONE"` | no |

### Health Check Object

The `health_check` variable accepts an object with the following attributes:

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| type | Health check type: "tcp", "http", or "https" | `string` | yes |
| port | Port number for health check | `number` | no |
| port_name | Port name for health check | `string` | no |
| check_interval_sec | How often to send health checks (seconds) | `number` | no |
| timeout_sec | How long to wait for response (seconds) | `number` | no |
| healthy_threshold | Number of consecutive successes required | `number` | no |
| unhealthy_threshold | Number of consecutive failures required | `number` | no |
| enable_log | Enable health check logging | `bool` | no |
| proxy_header | Proxy header type (NONE, PROXY_V1) | `string` | no |
| request | Request string (TCP only) | `string` | no |
| response | Expected response string | `string` | no |
| request_path | HTTP(S) request path | `string` | no |
| host | HTTP(S) host header | `string` | no |

### Backend Object

Each backend in the `backends` list accepts the following attributes:

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| group | Full URL of the instance group or network endpoint group | `string` | yes |
| balancing_mode | Balancing mode (CONNECTION, RATE, UTILIZATION) | `string` | no |
| capacity_scaler | Multiplier for backend capacity (0.0 to 1.0) | `number` | no |
| max_rate_per_instance | Maximum requests per second per instance | `number` | no |
| max_rate_per_endpoint | Maximum requests per second per endpoint | `number` | no |

## Outputs

| Name | Description |
|------|-------------|
| backend_service_id | The ID of the backend service |
| backend_service_self_link | The self-link of the backend service |
| backend_service_name | The name of the backend service |
| health_check_id | The ID of the health check |
| health_check_self_link | The self-link of the health check |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| google | >= 7.0.0, < 8.0.0 |
| google-beta | >= 7.0.0, < 8.0.0 |

## Changelog

See [CHANGELOG.md](./CHANGELOG.md) for version history and changes.