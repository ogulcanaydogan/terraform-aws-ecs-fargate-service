output "service_arn" {
  description = "ARN of the ECS service."
  value       = aws_ecs_service.this.id
}

output "service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.this.name
}

output "task_definition_arn" {
  description = "ARN of the ECS task definition."
  value       = aws_ecs_task_definition.this.arn
}

output "task_definition_family" {
  description = "Family of the ECS task definition."
  value       = aws_ecs_task_definition.this.family
}

output "task_definition_revision" {
  description = "Revision number of the ECS task definition."
  value       = aws_ecs_task_definition.this.revision
}

output "log_group_name" {
  description = "Name of the CloudWatch log group."
  value       = aws_cloudwatch_log_group.this.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group."
  value       = aws_cloudwatch_log_group.this.arn
}

output "container_name" {
  description = "Name of the container in the task definition."
  value       = var.name
}

output "container_port" {
  description = "Port the container listens on."
  value       = var.container_port
}

output "autoscaling_target_id" {
  description = "ID of the auto scaling target (if enabled)."
  value       = var.enable_autoscaling ? aws_appautoscaling_target.this[0].id : null
}

output "cpu_scaling_policy_arn" {
  description = "ARN of the CPU auto scaling policy (if enabled)."
  value       = var.enable_autoscaling ? aws_appautoscaling_policy.cpu[0].arn : null
}

output "memory_scaling_policy_arn" {
  description = "ARN of the memory auto scaling policy (if enabled)."
  value       = var.enable_autoscaling && var.autoscaling_memory_target != null ? aws_appautoscaling_policy.memory[0].arn : null
}
