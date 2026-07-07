

variable "file" {
  description = "value"
  type        = string
  nullable    = false
}

variable "parameters" {
  description = "value"
  type        = map(any)
  nullable    = false
}

variable "format" {
  description = "The result format. Choose either (Text, Json, Yaml or Tfvars)"
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.format == null ? true : contains(["Text", "Json", "Yaml", "Tfvars"], var.format)
    error_message = "The format must be one of: Text, Json, Yaml, Tfvars."
  }
}
