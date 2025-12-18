output "service_arn" {
  description = "Example service ARN output."
  value       = module.service.service_arn
}

output "task_definition_arn" {
  description = "Example task definition ARN output."
  value       = module.service.task_definition_arn
}

output "log_group_name" {
  description = "Example log group name output."
  value       = module.service.log_group_name
}
