
# ----------------------------------------------------------------------------
# Example: basic resource naming with an index range.
#
# Declare the schema once, then generate a full set of sequentially
# named resources in a single naming-generator call.
# ----------------------------------------------------------------------------

module "template" {
  source = "LemurDaniel/templatefile/random"

  file = "${path.root}/file.tfvars"
  parameters = {
    insertion01 = "This is a test1"
    insertion02 = "This is a test2"
    insertion03 = "This is a test3"
  }
}

output "result" {
  value = module.template
}
