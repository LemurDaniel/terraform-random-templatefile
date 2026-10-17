output "result" {
  value = local.file_encoded

  precondition {
    condition     = length(local.missing_parameters) == 0
    error_message = "The template ${var.file} contains placeholders without a matching key in var.parameters: ${join(", ", local.missing_parameters)}"
  }
}
