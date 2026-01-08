# terraform-aws-ecs-fargate-service

Terraform module that provisions an ECS Fargate service with auto-scaling, health checks, deployment circuit breaker, and CloudWatch logging. Supports optional load balancer integration.

## Features

- **Task role support** - IAM role for container AWS API access
- **Auto-scaling** - CPU and memory-based target tracking
- **Deployment circuit breaker** - Automatic rollback on failed deployments
- **Container health checks** - Configurable health check commands
- **Log retention** - Configurable CloudWatch log retention
- **Zero-downtime deployments** - Configurable deployment percentages
- **Optional load balancer** - Works with or without ALB/NLB
- **Container overrides** - Command, entrypoint, working directory

## Usage

### Basic Example

```hcl
module "service" {
  source = "ogulcanaydogan/ecs-fargate-service/aws"

  name               = "my-api"
  cluster_arn        = "arn:aws:ecs:us-east-1:123456789012:cluster/my-cluster"
  subnet_ids         = ["subnet-abc123", "subnet-def456"]
  security_group_ids = ["sg-abc123"]
  target_group_arn   = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-tg/abc123"

  container_image    = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-api:latest"
  container_port     = 8080
  execution_role_arn = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"

  tags = {
    Environment = "production"
  }
}
```

### With Task Role (AWS API Access)

```hcl
module "service" {
  source = "ogulcanaydogan/ecs-fargate-service/aws"

  name               = "my-api"
  cluster_arn        = aws_ecs_cluster.main.arn
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.ecs.id]
  target_group_arn   = aws_lb_target_group.main.arn

  container_image    = "${aws_ecr_repository.api.repository_url}:latest"
  container_port     = 8080
  execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn      = aws_iam_role.ecs_task.arn  # For S3, DynamoDB, etc.

  cpu    = 512
  memory = 1024

  env = [
    { name = "APP_ENV", value = "production" },
    { name = "LOG_LEVEL", value = "info" }
  ]

  secrets = [
    { name = "DB_PASSWORD", value_from = "arn:aws:secretsmanager:us-east-1:123456789012:secret:db-password" }
  ]
}
```

### With Auto-Scaling

```hcl
module "service" {
  source = "ogulcanaydogan/ecs-fargate-service/aws"

  name               = "my-api"
  cluster_arn        = aws_ecs_cluster.main.arn
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.ecs.id]
  target_group_arn   = aws_lb_target_group.main.arn

  container_image    = "my-image:latest"
  container_port     = 8080
  execution_role_arn = aws_iam_role.ecs_execution.arn

  desired_count = 2

  # Auto-scaling
  enable_autoscaling       = true
  autoscaling_min_capacity = 2
  autoscaling_max_capacity = 10
  autoscaling_cpu_target   = 70
  autoscaling_memory_target = 80

  tags = {
    Environment = "production"
  }
}
```

### With Health Check

```hcl
module "service" {
  source = "ogulcanaydogan/ecs-fargate-service/aws"

  name               = "my-api"
  cluster_arn        = aws_ecs_cluster.main.arn
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.ecs.id]
  target_group_arn   = aws_lb_target_group.main.arn

  container_image    = "my-image:latest"
  container_port     = 8080
  execution_role_arn = aws_iam_role.ecs_execution.arn

  # Container health check
  health_check_command      = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
  health_check_interval     = 30
  health_check_timeout      = 5
  health_check_retries      = 3
  health_check_start_period = 60
}
```

### Without Load Balancer (Service Discovery)

```hcl
module "worker" {
  source = "ogulcanaydogan/ecs-fargate-service/aws"

  name               = "worker"
  cluster_arn        = aws_ecs_cluster.main.arn
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.ecs.id]

  container_image    = "my-worker:latest"
  container_port     = 8080
  execution_role_arn = aws_iam_role.ecs_execution.arn

  # No load balancer
  enable_load_balancer = false

  desired_count = 3
}
```

### Custom Deployment Configuration

```hcl
module "service" {
  source = "ogulcanaydogan/ecs-fargate-service/aws"

  name               = "my-api"
  cluster_arn        = aws_ecs_cluster.main.arn
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.ecs.id]
  target_group_arn   = aws_lb_target_group.main.arn

  container_image    = "my-image:latest"
  container_port     = 8080
  execution_role_arn = aws_iam_role.ecs_execution.arn

  # Deployment configuration
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  enable_circuit_breaker             = true
  enable_circuit_breaker_rollback    = true
  wait_for_steady_state              = true

  # Log retention
  log_retention_days = 14
}
```

## Inputs

### Required

| Name | Description | Type |
|------|-------------|------|
| `name` | Name prefix for ECS resources | `string` |
| `cluster_arn` | ARN of the ECS cluster | `string` |
| `subnet_ids` | List of subnet IDs for task ENIs | `list(string)` |
| `security_group_ids` | List of security group IDs | `list(string)` |
| `container_image` | Container image URI | `string` |
| `container_port` | Port the container listens on | `number` |
| `execution_role_arn` | IAM execution role ARN | `string` |

### Task Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `task_role_arn` | IAM task role for AWS API access | `string` | `null` |
| `cpu` | Fargate CPU units (256, 512, 1024, 2048, 4096) | `number` | `256` |
| `memory` | Fargate memory in MiB | `number` | `512` |
| `desired_count` | Number of tasks | `number` | `1` |
| `assign_public_ip` | Assign public IP to tasks | `bool` | `false` |

### Container Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `container_command` | Override container CMD | `list(string)` | `null` |
| `container_entrypoint` | Override container ENTRYPOINT | `list(string)` | `null` |
| `container_working_directory` | Working directory | `string` | `null` |
| `env` | Environment variables | `list(object)` | `[]` |
| `secrets` | Secrets from Secrets Manager/Parameter Store | `list(object)` | `[]` |

### Health Check

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `health_check_command` | Health check command | `list(string)` | `null` |
| `health_check_interval` | Interval in seconds | `number` | `30` |
| `health_check_timeout` | Timeout in seconds | `number` | `5` |
| `health_check_retries` | Retries before unhealthy | `number` | `3` |
| `health_check_start_period` | Grace period in seconds | `number` | `60` |

### Load Balancer

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `enable_load_balancer` | Attach to load balancer | `bool` | `true` |
| `target_group_arn` | Target group ARN | `string` | `null` |

### Deployment

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `deployment_maximum_percent` | Max tasks during deployment | `number` | `200` |
| `deployment_minimum_healthy_percent` | Min healthy during deployment | `number` | `100` |
| `enable_circuit_breaker` | Enable deployment circuit breaker | `bool` | `true` |
| `enable_circuit_breaker_rollback` | Auto rollback on failure | `bool` | `true` |
| `force_new_deployment` | Force deployment on apply | `bool` | `false` |
| `wait_for_steady_state` | Wait for steady state | `bool` | `false` |

### Logging

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `log_retention_days` | Log retention (0 = never expire) | `number` | `30` |

### Auto Scaling

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `enable_autoscaling` | Enable auto scaling | `bool` | `false` |
| `autoscaling_min_capacity` | Minimum tasks | `number` | `1` |
| `autoscaling_max_capacity` | Maximum tasks | `number` | `4` |
| `autoscaling_cpu_target` | Target CPU percentage | `number` | `70` |
| `autoscaling_memory_target` | Target memory percentage | `number` | `null` |
| `autoscaling_scale_in_cooldown` | Scale in cooldown (seconds) | `number` | `300` |
| `autoscaling_scale_out_cooldown` | Scale out cooldown (seconds) | `number` | `60` |

### Other

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `tags` | Tags for resources | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `service_arn` | ARN of the ECS service |
| `service_name` | Name of the ECS service |
| `task_definition_arn` | ARN of the task definition |
| `task_definition_family` | Task definition family |
| `task_definition_revision` | Task definition revision |
| `log_group_name` | CloudWatch log group name |
| `log_group_arn` | CloudWatch log group ARN |
| `container_name` | Container name |
| `container_port` | Container port |
| `autoscaling_target_id` | Auto scaling target ID |
| `cpu_scaling_policy_arn` | CPU scaling policy ARN |
| `memory_scaling_policy_arn` | Memory scaling policy ARN |

## Fargate CPU/Memory Combinations

| CPU (units) | Memory (MiB) |
|-------------|--------------|
| 256 | 512, 1024, 2048 |
| 512 | 1024, 2048, 3072, 4096 |
| 1024 | 2048, 3072, 4096, 5120, 6144, 7168, 8192 |
| 2048 | 4096 - 16384 (1024 increments) |
| 4096 | 8192 - 30720 (1024 increments) |

## IAM Roles

### Execution Role (Required)

The execution role allows ECS to pull images and write logs:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
```

### Task Role (Optional)

The task role allows your application to access AWS services:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```

## Examples

See [`examples/basic`](./examples/basic) for a working configuration.
