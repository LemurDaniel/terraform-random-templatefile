# ----------------------------------------------------------------------------
# Example: render an app config from file.tfvars.
#
# Placeholders are reused inside larger strings (url, host). Unlike YAML and
# JSON, every placeholder must sit inside quotes (terraform fmt parses .tfvars
# as HCL), so numbers and bools come back as strings here.
# ----------------------------------------------------------------------------

module "template" {
  source  = "LemurDaniel/templatefile/random"
  version = ">= 1.1.0"

  file = "${path.root}/file.tfvars"
  parameters = {
    appName        = "shop"
    environment    = "prod"
    maxConnections = 100
    debug          = false
  }
}

output "result" {
  value = module.template.result
  # {
  #   app      = { name = "shop", environment = "prod", url = "https://shop.prod.example.com" }
  #   database = { host = "shop-db.prod.internal", port = 5432, max_connections = "100" }
  #   features = { debug = "false" }
  #   tags     = ["shop", "prod"]
  # }
}
