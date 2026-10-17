
run "uppercase_extension_is_detected" {
  command = plan

  variables {
    file       = "tests/fixtures/upper.YAML"
    parameters = { x = "v" }
  }

  assert {
    condition     = output.result == { a = "v", b = "v" }
    error_message = "got: ${jsonencode(output.result)}"
  }
}

run "missing_parameter_is_reported" {
  command = plan

  variables {
    file       = "tests/fixtures/missing.json"
    parameters = { x = "v" }
  }

  expect_failures = [output.result]
}

run "list_parameter_is_rejected" {
  command = plan

  variables {
    file       = "tests/fixtures/upper.YAML"
    parameters = { x = ["a", "b"] }
  }

  expect_failures = [var.parameters]
}
