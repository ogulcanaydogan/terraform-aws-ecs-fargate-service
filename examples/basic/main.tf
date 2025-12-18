variable "region" {
  description = "AWS region for the provider."
  type        = string
  default     = "us-east-1"
}

module "service" {
  source = "../.."

  name               = "example"
  cluster_arn        = "arn:aws:ecs:us-east-1:123456789012:cluster/example"
  subnet_ids         = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]
  security_group_ids = ["sg-0123456789abcdef0"]
  target_group_arn   = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/example/0123456789abcdef"

  container_image = "public.ecr.aws/docker/library/nginx:latest"
  container_port  = 80

  execution_role_arn = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"

  desired_count = 1
  cpu           = 256
  memory        = 512

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
