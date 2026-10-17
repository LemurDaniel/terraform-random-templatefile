# ----------------------------------------------------------------------------
# Example: render an app config from file.yaml.
#
# Placeholders are reused inside larger strings (url, host), and numbers and
# bools are inserted unquoted, so they decode to native number/bool values.
# ----------------------------------------------------------------------------

module "template" {
  source  = "LemurDaniel/templatefile/random"
  version = ">= 1.1.0"

  file = "${path.root}/file.yaml"
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
  #   database = { host = "shop-db.prod.internal", port = 5432, max_connections = 100 }
  #   features = { debug = false }
  #   tags     = ["shop", "prod"]
  # }
}
