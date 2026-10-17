

variable "file" {
  description = "Path to the template file to render. Occurrences placeholders are replaced with values from var.parameters. The file extension (yaml/yml, json, tfvars, or other) determines the default decoding format unless var.format overrides it."
  type        = string
  nullable    = false
}

variable "parameters" {
  description = "Map of parameter names to values used to substitute placeholders in the template file."
  type        = map(any)
  nullable    = false

  validation {
    condition     = alltrue([for value in values(var.parameters) : can(tostring(value))])
    error_message = "All parameter values must be strings, numbers or bools; lists and maps cannot be substituted into the file."
  }
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
