variable "name" {
  description = "Name prefix used for ECS resources."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0 && length(var.name) <= 255
    error_message = "name must be between 1 and 255 characters."
  }
}

variable "cluster_arn" {
  description = "ARN of the ECS cluster to run the service in."
  type        = string

  validation {
    condition     = can(regex("^arn:aws[a-zA-Z-]*:ecs:", var.cluster_arn))
    error_message = "cluster_arn must be a valid ECS cluster ARN."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs for the service ENIs."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet_id must be provided."
  }
}

variable "security_group_ids" {
  description = "List of security group IDs attached to the service ENIs."
  type        = list(string)

  validation {
    condition     = length(var.security_group_ids) > 0
    error_message = "At least one security_group_id must be provided."
  }
}

variable "container_image" {
  description = "Container image URI (e.g., ECR URI or Docker Hub image)."
  type        = string

  validation {
    condition     = length(trimspace(var.container_image)) > 0
    error_message = "container_image must not be empty."
  }
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535
    error_message = "container_port must be between 1 and 65535."
  }
}

# IAM Roles
variable "execution_role_arn" {
  description = "IAM execution role ARN for ECS agent (pulling images, writing logs)."
  type        = string

  validation {
    condition     = can(regex("^arn:aws[a-zA-Z-]*:iam::", var.execution_role_arn))
    error_message = "execution_role_arn must be a valid IAM role ARN."
  }
}

variable "task_role_arn" {
  description = "IAM task role ARN for container AWS API access. If null, containers have no AWS permissions."
  type        = string
  default     = null

  validation {
    condition     = var.task_role_arn == null ? true : can(regex("^arn:aws[a-zA-Z-]*:iam::", var.task_role_arn))
    error_message = "task_role_arn must be a valid IAM role ARN."
  }
}

# Task Configuration
variable "cpu" {
  description = "Fargate task CPU units (256, 512, 1024, 2048, 4096)."
  type        = number
  default     = 256

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.cpu)
    error_message = "cpu must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "memory" {
  description = "Fargate task memory in MiB. Must be compatible with CPU setting."
  type        = number
  default     = 512

  validation {
    condition     = var.memory >= 512 && var.memory <= 30720
    error_message = "memory must be between 512 and 30720 MiB."
  }
}

variable "desired_count" {
  description = "Number of desired tasks."
  type        = number
  default     = 1

  validation {
    condition     = var.desired_count >= 0
    error_message = "desired_count must be zero or greater."
  }
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP to the tasks. Enable for public subnets without NAT."
  type        = bool
  default     = false
}

# Container Configuration
variable "container_command" {
  description = "Command to run in the container (overrides Dockerfile CMD)."
  type        = list(string)
  default     = null
}

variable "container_entrypoint" {
  description = "Entry point for the container (overrides Dockerfile ENTRYPOINT)."
  type        = list(string)
  default     = null
}

variable "container_working_directory" {
  description = "Working directory for the container."
  type        = string
  default     = null
}

variable "env" {
  description = "List of environment variables for the container."
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "secrets" {
  description = "List of secrets from Secrets Manager or Parameter Store."
  type = list(object({
    name       = string
    value_from = string
  }))
  default = []
}

# Health Check
variable "health_check_command" {
  description = "Container health check command (e.g., ['CMD-SHELL', 'curl -f http://localhost/ || exit 1'])."
  type        = list(string)
  default     = null
}

variable "health_check_interval" {
  description = "Time between health checks in seconds."
  type        = number
  default     = 30

  validation {
    condition     = var.health_check_interval >= 5 && var.health_check_interval <= 300
    error_message = "health_check_interval must be between 5 and 300 seconds."
  }
}

variable "health_check_timeout" {
  description = "Time to wait for health check response in seconds."
  type        = number
  default     = 5

  validation {
    condition     = var.health_check_timeout >= 2 && var.health_check_timeout <= 60
    error_message = "health_check_timeout must be between 2 and 60 seconds."
  }
}

variable "health_check_retries" {
  description = "Number of retries before marking container unhealthy."
  type        = number
  default     = 3

  validation {
    condition     = var.health_check_retries >= 1 && var.health_check_retries <= 10
    error_message = "health_check_retries must be between 1 and 10."
  }
}

variable "health_check_start_period" {
  description = "Grace period for container startup before health checks count."
  type        = number
  default     = 60

  validation {
    condition     = var.health_check_start_period >= 0 && var.health_check_start_period <= 300
    error_message = "health_check_start_period must be between 0 and 300 seconds."
  }
}

# Load Balancer
variable "enable_load_balancer" {
  description = "Whether to attach the service to a load balancer."
  type        = bool
  default     = true
}

variable "target_group_arn" {
  description = "ARN of the ALB/NLB target group for the service."
  type        = string
  default     = null

  validation {
    condition     = var.target_group_arn == null ? true : can(regex("^arn:aws[a-zA-Z-]*:elasticloadbalancing:", var.target_group_arn))
    error_message = "target_group_arn must be a valid target group ARN."
  }
}

# Deployment Configuration
variable "deployment_maximum_percent" {
  description = "Maximum percentage of tasks that can run during deployment."
  type        = number
  default     = 200

  validation {
    condition     = var.deployment_maximum_percent >= 100 && var.deployment_maximum_percent <= 400
    error_message = "deployment_maximum_percent must be between 100 and 400."
  }
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum percentage of healthy tasks during deployment."
  type        = number
  default     = 100

  validation {
    condition     = var.deployment_minimum_healthy_percent >= 0 && var.deployment_minimum_healthy_percent <= 100
    error_message = "deployment_minimum_healthy_percent must be between 0 and 100."
  }
}

variable "enable_circuit_breaker" {
  description = "Enable deployment circuit breaker to automatically rollback failed deployments."
  type        = bool
  default     = true
}

variable "enable_circuit_breaker_rollback" {
  description = "Enable automatic rollback when circuit breaker triggers."
  type        = bool
  default     = true
}

variable "force_new_deployment" {
  description = "Force a new deployment on every apply."
  type        = bool
  default     = false
}

variable "wait_for_steady_state" {
  description = "Wait for the service to reach steady state before completing."
  type        = bool
  default     = false
}

# Logging
variable "log_retention_days" {
  description = "CloudWatch log retention in days. Set to 0 for never expire."
  type        = number
  default     = 30

  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.log_retention_days)
    error_message = "log_retention_days must be a valid CloudWatch Logs retention value."
  }
}

# Auto Scaling
variable "enable_autoscaling" {
  description = "Enable auto scaling for the service."
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks for auto scaling."
  type        = number
  default     = 1

  validation {
    condition     = var.autoscaling_min_capacity >= 0
    error_message = "autoscaling_min_capacity must be zero or greater."
  }
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks for auto scaling."
  type        = number
  default     = 4

  validation {
    condition     = var.autoscaling_max_capacity >= 1
    error_message = "autoscaling_max_capacity must be at least 1."
  }
}

variable "autoscaling_cpu_target" {
  description = "Target CPU utilization percentage for auto scaling."
  type        = number
  default     = 70

  validation {
    condition     = var.autoscaling_cpu_target >= 1 && var.autoscaling_cpu_target <= 100
    error_message = "autoscaling_cpu_target must be between 1 and 100."
  }
}

variable "autoscaling_memory_target" {
  description = "Target memory utilization percentage for auto scaling. Set to null to disable."
  type        = number
  default     = null

  validation {
    condition     = var.autoscaling_memory_target == null ? true : (var.autoscaling_memory_target >= 1 && var.autoscaling_memory_target <= 100)
    error_message = "autoscaling_memory_target must be between 1 and 100."
  }
}

variable "autoscaling_scale_in_cooldown" {
  description = "Cooldown period in seconds before scaling in."
  type        = number
  default     = 300

  validation {
    condition     = var.autoscaling_scale_in_cooldown >= 0
    error_message = "autoscaling_scale_in_cooldown must be zero or greater."
  }
}

variable "autoscaling_scale_out_cooldown" {
  description = "Cooldown period in seconds before scaling out."
  type        = number
  default     = 60

  validation {
    condition     = var.autoscaling_scale_out_cooldown >= 0
    error_message = "autoscaling_scale_out_cooldown must be zero or greater."
  }
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
  default     = {}
}
