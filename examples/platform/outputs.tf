output "account_id" {
  description = "The account id where the pipeline is running"
  value       = local.account_id
}

output "region" {
  description = "The region where the pipeline is running"
  value       = local.region
}

output "tags" {
  description = "The tags to apply to all resources"
  value       = local.tags
}
