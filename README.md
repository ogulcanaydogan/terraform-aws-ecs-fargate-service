# terraform-aws-ecs-fargate-service

A minimal AWS Terraform module that provisions an ECS Fargate service wired to an existing Application Load Balancer target group. The module creates a task definition with AWS CloudWatch logging, an ECS service using `awsvpc` networking, and the supporting log group.

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

module "service" {
  source = "github.com/example/terraform-aws-ecs-fargate-service"

  name               = "example"
  cluster_arn        = "arn:aws:ecs:us-east-1:123456789012:cluster/example"
  subnet_ids         = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]
  security_group_ids = ["sg-0123456789abcdef0"]
  target_group_arn   = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/example/0123456789abcdef"

  container_image    = "public.ecr.aws/docker/library/nginx:latest"
  container_port     = 80
  execution_role_arn = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"

  env = [
    {
      name  = "EXAMPLE_VAR"
      value = "hello"
    }
  ]

  tags = {
    Project = "example"
  }
}
```

For a complete, copy/pasteable configuration see [`examples/basic`](./examples/basic).

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| name | Name prefix used for ECS resources. | `string` | n/a | yes |
| cluster_arn | ARN of the ECS cluster to run the service in. | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for the service ENIs. | `list(string)` | n/a | yes |
| security_group_ids | List of security group IDs attached to the service ENIs. | `list(string)` | n/a | yes |
| target_group_arn | ARN of the ALB target group for the service. | `string` | n/a | yes |
| container_image | Container image for the task definition. | `string` | n/a | yes |
| container_port | Port the container listens on. | `number` | n/a | yes |
| execution_role_arn | Execution role ARN for the task definition. | `string` | n/a | yes |
| desired_count | Number of desired tasks. | `number` | `1` | no |
| cpu | Fargate task CPU units. | `number` | `256` | no |
| memory | Fargate task memory (MiB). | `number` | `512` | no |
| assign_public_ip | Whether to assign a public IP to the tasks. | `bool` | `false` | no |
| env | List of environment variables for the container. | `list(object({ name = string, value = string }))` | `[]` | no |
| secrets | List of secrets to pass to the container (name and value_from). | `list(object({ name = string, value_from = string }))` | `[]` | no |
| tags | Tags applied to created resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| --- | --- |
| service_arn | ARN of the ECS service. |
| task_definition_arn | ARN of the ECS task definition. |
| log_group_name | Name of the CloudWatch log group. |

## Examples

See [`examples/basic`](./examples/basic) for a working configuration that can be used with `terraform init` and `terraform validate` without creating real AWS infrastructure.
