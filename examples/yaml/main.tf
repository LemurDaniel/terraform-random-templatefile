# ----------------------------------------------------------------------------
# Example: render file.yaml with ${...} substitution and decode it.
# ----------------------------------------------------------------------------

module "template" {
  source = "LemurDaniel/templatefile/random"

  file = "${path.root}/file.yaml"
  parameters = {
    insertion01 = "This is a test1"
    insertion02 = "This is a test2"
    insertion03 = "This is a test3"
  }
}

output "result" {
  value = module.template.result
}
