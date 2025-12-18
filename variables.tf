variable "name" {
  description = "Name prefix used for ECS resources."
  type        = string

  validation {
    condition     = length(trim(var.name)) > 0
    error_message = "name must not be empty."
  }
}

variable "cluster_arn" {
  description = "ARN of the ECS cluster to run the service in."
  type        = string

  validation {
    condition     = length(trim(var.cluster_arn)) > 0
    error_message = "cluster_arn must not be empty."
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

variable "target_group_arn" {
  description = "ARN of the ALB target group for the service."
  type        = string

  validation {
    condition     = length(trim(var.target_group_arn)) > 0
    error_message = "target_group_arn must not be empty."
  }
}

variable "container_image" {
  description = "Container image for the task definition."
  type        = string

  validation {
    condition     = length(trim(var.container_image)) > 0
    error_message = "container_image must not be empty."
  }
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number

  validation {
    condition     = var.container_port > 0 && var.container_port <= 65535
    error_message = "container_port must be between 1 and 65535."
  }
}

variable "execution_role_arn" {
  description = "Execution role ARN for the task definition."
  type        = string

  validation {
    condition     = length(trim(var.execution_role_arn)) > 0
    error_message = "execution_role_arn must not be empty."
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

variable "cpu" {
  description = "Fargate task CPU units."
  type        = number
  default     = 256

  validation {
    condition     = var.cpu > 0
    error_message = "cpu must be greater than zero."
  }
}

variable "memory" {
  description = "Fargate task memory (MiB)."
  type        = number
  default     = 512

  validation {
    condition     = var.memory > 0
    error_message = "memory must be greater than zero."
  }
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP to the tasks."
  type        = bool
  default     = false
}

variable "env" {
  description = "List of environment variables for the container."
  type = list(object({
    name  = string
    value = string
  }))
  default = []

  validation {
    condition = alltrue([
      for item in var.env : length(trim(item.name)) > 0 && length(item.value) > 0
    ])
    error_message = "env entries must have non-empty name and value."
  }
}

variable "secrets" {
  description = "List of secrets to pass to the container (name and value_from)."
  type = list(object({
    name       = string
    value_from = string
  }))
  default = []

  validation {
    condition = alltrue([
      for secret in var.secrets : length(trim(secret.name)) > 0 && length(trim(secret.value_from)) > 0
    ])
    error_message = "secrets entries must have non-empty name and value_from."
  }
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
  default     = {}
}
