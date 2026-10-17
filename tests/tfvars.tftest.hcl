
run "tfvars_example" {
  command = plan

  variables {
    file = "examples/tfvars/file.tfvars"
    parameters = {
      appName        = "shop"
      environment    = "prod"
      maxConnections = 100
      debug          = false
    }
  }

  # verify the tfvars file is decoded and its tokens are substituted correctly.
  assert {
    condition = jsonencode(output.result) == jsonencode({
      app = {
        environment = "prod"
        name        = "shop"
        url         = "https://shop.prod.example.com"
      }
      database = {
        host            = "shop-db.prod.internal"
        max_connections = "100"
        port            = 5432
      }
      features = {
        debug = "false"
      }
      tags = ["shop", "prod"]
    })
    error_message = "got: ${jsonencode(output.result)}"
  }
}
