
locals {

  split_sequence = "~~~"
  end_sequence   = "}"
  start_sequence = join("", ["$", "{"])
  regex_sequence = join("", ["(", "\\", local.start_sequence, "[a-zA-Z0-9]+", local.end_sequence, ")"])

  file_raw = replace(
    file(var.file),
    "/${local.regex_sequence}/",
    "${local.split_sequence}$1${local.split_sequence}"
  )

  file_split = [
    // This splits the file into segments for each occurance of ${...}
    for segment in split(local.split_sequence, local.file_raw) :

    // This replaces each segment with its parameter for the occurance of ${...}
    // Unknown placeholders are left as-is here and reported by the precondition on output.result.
    !can(regex(local.regex_sequence, segment)) ? segment : tostring(lookup(
      var.parameters,
      trimsuffix(trimprefix(segment, local.start_sequence), local.end_sequence),
      segment
    ))
  ]

  placeholders = distinct(flatten(regexall(local.regex_sequence, file(var.file))))
  missing_parameters = sort([
    for placeholder in local.placeholders :
    placeholder if !contains(keys(var.parameters), trimsuffix(trimprefix(placeholder, local.start_sequence), local.end_sequence))
  ])

}

locals {

  file_ending = lower(reverse(split(".", var.file))[0])
  encoding = coalesce(var.format,
    contains(["yaml", "yml"], local.file_ending) ? "Yaml" :
    contains(["json"], local.file_ending) ? "Json" :
    contains(["tfvars"], local.file_ending) ? "Tfvars" : "Text"
  )

  file_join = join("", local.file_split)
  // Skip decoding while placeholders are missing, so the precondition reports them instead of a decode error.
  file_encoded = length(local.missing_parameters) > 0 ? null : [for entry in [
    local.encoding == "Yaml" ? yamldecode(local.file_join) : null,
    local.encoding == "Json" ? jsondecode(local.file_join) : null,
    local.encoding == "Tfvars" ? provider::terraform::decode_tfvars(local.file_join) : null,
    local.file_join
  ] : entry if entry != null][0]
}
