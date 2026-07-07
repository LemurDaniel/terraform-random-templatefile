
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
    !can(regex(local.regex_sequence, segment)) ? segment : one([
      for param, value in var.parameters :
      value if "${segment}" == "${local.start_sequence}${param}${local.end_sequence}"
    ])
  ]

}

locals {

  file_ending = reverse(split(".", var.file))[0]
  encoding = coalesce(var.format,
    contains(["yaml", "yml"], local.file_ending) ? "Yaml" :
    contains(["json"], local.file_ending) ? "Json" :
    contains(["tfvars"], local.file_ending) ? "Tfvars" : "Text"
  )

  file_join  = join("", local.file_split)
  file_encoded = [ for entry in [
    local.encoding == "Yaml" ? yamldecode(local.file_join) : null,
    local.encoding == "Json" ? jsondecode(local.file_join) : null,
    local.encoding == "Tfvars" ? provider::terraform::decode_tfvars(local.file_join) : null,
    local.file_join
  ] : entry if entry != null ][0]
}
