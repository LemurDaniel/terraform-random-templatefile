
# Terraform Random Template Module

<div align="center">

<br><br>

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![YAML](https://img.shields.io/badge/YAML-CB171E?style=for-the-badge&logo=yaml&logoColor=white)
![JSON](https://img.shields.io/badge/JSON-000000?style=for-the-badge&logo=json&logoColor=white)
![HCL](https://img.shields.io/badge/HCL-000000?style=for-the-badge&logo=terraform&logoColor=white)

[![Terraform Registry](https://img.shields.io/badge/Terraform%20Registry-LemurDaniel%2Ftemplatefile%2Frandom-844FBA?style=for-the-badge&logo=terraform&logoColor=white)](https://registry.terraform.io/modules/LemurDaniel/templatefile/random/latest)

Render a file through simple `${token}` substitution, then decode it into a native Terraform value.

</div>

```hcl
module "template" {
  source = "LemurDaniel/templatefile/random"

  file = "${path.root}/config.yaml"
  parameters = {
    environment = "development"
    name        = "myapp"
  }
}

output "config" {
  value = module.template.result
}
```

---

## Why This Module?

- **Format-agnostic** — works with YAML, JSON, `.tfvars`, or plain text; the format is auto-detected from the file extension (or set explicitly).
- **Not HCL interpolation** — the file is read as plain literal text via `file()`, so `${TOKEN}` placeholders don't need to be valid Terraform expressions. Your YAML/JSON/tfvars stays valid, parseable data on its own, with placeholders anywhere a value is expected.
- **Decoded, not just substituted** — after tokens are replaced, the result is run through `yamldecode`/`jsondecode`/`decode_tfvars` so you get a native Terraform object/list/string back, not a raw string you have to decode yourself.
- **Reusable config as data** — keep naming schemes, feature flags, or any structured config in a file, inject a handful of caller-specific values, and consume the result as a regular Terraform value.

---

## 🚀 Quick Start

Given a YAML file with `${...}` placeholders:

```yaml
# config.yaml
environment: ${environment}
name:        ${name}
replicas:    3
```

```hcl
module "template" {
  source = "LemurDaniel/template/random"

  file = "${path.root}/config.yaml"
  parameters = {
    environment = "production"
    name        = "myapp"
  }
}

output "result" {
  value = module.template.result
  # {
  #   environment = "production"
  #   name        = "myapp"
  #   replicas    = 3
  # }
}
```

> [!NOTE]
> Full runnable examples live under [examples/](examples/): [json](examples/json/), [yaml](examples/yaml/), [tfvars](examples/tfvars/) — the same structure rendered from each supported file format.

---

## ⚙️ How It Works

### 🔤 Token Syntax

Every occurrence of `${NAME}` in the file (`NAME` being alphanumeric) is treated as a placeholder and replaced with `var.parameters["NAME"]`:

```yaml
test: ${insertion01}
```

with

```hcl
parameters = {
  insertion01 = "This is a test1"
}
```

becomes, after substitution:

```yaml
test: This is a test1
```

> [!IMPORTANT]
> Every `${TOKEN}` found in the file **must** have a matching key in `parameters`, or the module fails to evaluate. There is no "leave as-is" fallback for unmatched tokens.

Because substitution happens on the raw file text *before* any decoding, the tokens don't need to sit inside quotes or otherwise be valid syntax for the target format — the placeholder is a plain string search-and-replace.

### 📄 Format Detection & Decoding

After substitution, the resulting text is decoded according to `format` (explicit) or the file's extension (auto-detected):

| Extension | Format | Decoded with |
|---|---|---|
| `.yaml`, `.yml` | `Yaml` | `yamldecode()` |
| `.json` | `Json` | `jsondecode()` |
| `.tfvars` | `Tfvars` | `provider::terraform::decode_tfvars()` |
| anything else | `Text` | returned as a raw string |

`format` can be set explicitly to override the extension-based guess, e.g. to decode a `.txt` file as YAML.

---

## 📥 Inputs

| Name | Type | Required | Description |
|---|---|---|---|
| `file` | `string` | Yes | Path to the file to read (typically `"${path.root}/..."`). |
| `parameters` | `map(any)` | Yes | Values substituted into `${TOKEN}` placeholders found in the file. |
| `format` | `string` | No (default `null`, auto-detected) | Overrides format detection. One of `Text`, `Json`, `Yaml`, `Tfvars`. |

## 📤 Outputs

| Name | Description |
|---|---|
| `result` | The decoded value: an object/list for `Yaml`/`Json`/`Tfvars`, or a plain string for `Text`. |

---

## Examples

Full runnable configurations live under [examples/](examples/), each rendering the same token-substituted structure from a different file format:

- [json](examples/json/) — `file.json` decoded with `jsondecode()`.
- [yaml](examples/yaml/) — `file.yaml` decoded with `yamldecode()`.
- [tfvars](examples/tfvars/) — `file.tfvars` decoded with `decode_tfvars()`.

## License

[MIT](LICENSE)
