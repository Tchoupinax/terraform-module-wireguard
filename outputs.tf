output "clients_configs" {
  description = "The list of all generated clients"
  value       = data.template_file.client_config[*].rendered
}
