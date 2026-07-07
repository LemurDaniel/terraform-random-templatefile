default_parameters = {
  location    = "westeurope"
  environment = "development"
  name        = "myapp"
}

index_modifier = 1

enforce_lower_case = {
  default = true
  test    = "${insertion01}"
}

patterns = {
  default = "${insertion02}"

  AzureAD = {
    default = "${insertion03}"
  }
}
