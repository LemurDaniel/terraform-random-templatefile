
run "json_example" {
  command = plan

  variables {
    file = "examples/json/file.json"
    parameters = {
      insertion01 = "This is a test1"
      insertion02 = "This is a test2"
      insertion03 = "This is a test3"
    }
  }

  # verify the json file is decoded and its tokens are substituted correctly.
  assert {
    condition = output.result == {
      default_parameters = {
        location    = "westeurope"
        environment = "development"
        name        = "myapp"
      }
      index_modifier = 1
      enforce_lower_case = {
        default = true
        test    = "This is a test1"
      }
      patterns = {
        default = "This is a test2"
        AzureAD = {
          default = "This is a test3"
        }
      }
    }
    error_message = "Decoded json result is invalid"
  }
}
