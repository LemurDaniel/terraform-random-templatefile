---
name: terraform-tests
description: Write, run, and fix the native Terraform tests (.tftest.hcl) for this template-file module. Use when adding a test for a new format, file type or substitution case, when `terraform test` fails, when a rendered result needs to be asserted, or when the user asks to test / verify / validate the module ("add a test", "test schreiben", "tests laufen lassen", "warum failt der test").
---

# Testing the template-file module

```bash
terraform init -backend=false
terraform test
```

Requires Terraform 1.8+ (`provider::terraform::decode_tfvars` is a 1.8 provider function).
Every `*.tftest.hcl` in `tests/` runs; there is one file per format today
(`yaml`, `json`, `tfvars`).

## Fixtures

Tests point `file` at the template files under `examples/<format>/` and pass `parameters`.
Paths are relative to the **module root** (where `terraform test` runs), e.g.
`file = "examples/yaml/file.yaml"`.

Changing an example file therefore changes test expectations — update both in the same
commit. If a case needs input the examples should not show (missing placeholder, odd
extension, explicit `format` override), add a dedicated fixture under `tests/fixtures/`
rather than bending an example.

## `command = plan` is enough

The module declares no resources, only `locals` and the `result` output, so a plan fully
evaluates it. Always use `command = plan`.

## Asserting

```hcl
run "json_example" {
  command = plan
  variables {
    file       = "examples/json/file.json"
    parameters = { insertion01 = "a" }
  }
  assert {
    condition     = output.result.some.key == "a"
    error_message = "got: ${jsonencode(output.result)}"
  }
}
```

- Put the actual value into `error_message` (`jsonencode(...)` for objects) — `terraform test`
  does not print it otherwise.
- Comparing a whole decoded object with `==` works for maps/objects, but **lists decode as
  tuples** and can fail with "different types" against a list literal. Compare
  `jsonencode(...)` of both sides, or assert elements individually.
- For `Text` results, assert the exact string; watch trailing newlines from the file.

## Behaviour traps

- **Placeholders are `${name}` with `[a-zA-Z0-9]+` names only** — `${my_param}` or
  `${my-param}` is not matched and stays in the output literally.
- **An unknown placeholder fails the precondition on `output.result`** — test it with
  `expect_failures = [output.result]`.
- **List/map parameter values fail validation** — test with `expect_failures = [var.parameters]`.
- **A literal `~~~` in the file disappears** — it is the internal split marker.
- **Format detection uses the last `.` segment** of `file`, lower-cased: `yaml`/`yml` → Yaml, `json` →
  Json, `tfvars` → Tfvars, anything else → Text. `format` overrides it.
- Substitution happens **before** decoding, so a parameter value can break the document's
  syntax (e.g. a `:` or quote in YAML). Values in `parameters` are stringified via `join`.

## What is worth a test

One `run` per behaviour, named after it:

- each format decoding end to end
- `.yml` as well as `.yaml`
- `format` overriding the extension (e.g. a `.json` file read as `Text`)
- a placeholder used more than once
- a file with no placeholders
- an unknown extension falling back to `Text`

## Related

- A test change is its own commit — [git-commit-conventions](../git-commit-conventions/SKILL.md).
- The suite is a hard gate before tagging — [release](../release/SKILL.md).
