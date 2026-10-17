# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Module Does

A small Terraform module (Registry: `LemurDaniel/templatefile/random`) that reads a file, replaces `${name}` placeholders with values from a `parameters` map, and decodes the result into a native Terraform value (YAML, JSON, tfvars, or plain text). Unlike Terraform's built-in `templatefile()`, it does plain token substitution only — no expressions, loops, or conditionals.

## Commands

```bash
# Initialize (no backend needed)
terraform init -backend=false

# Run all tests (requires Terraform 1.8+)
terraform test

# Format / validate
terraform fmt -check -recursive
terraform validate
```

## Module Layout

The module lives in the repository root (no submodules):

- `variables.tf` — inputs: `file` (path), `parameters` (map), `format` (optional: `Text`, `Json`, `Yaml`, `Tfvars`)
- `locals.template.tf` — all logic (substitution and decoding)
- `outputfs.tf` — single output `result`
- `terraform.tf` — requires Terraform `>= 1.8.0` and the builtin `terraform` provider (for `provider::terraform::decode_tfvars`)
- `examples/{yaml,json,tfvars}/` — runnable example configs, each with a `file.*` template; the tests reuse these template files as fixtures
- `tests/*.tftest.hcl` — one test file per format

## How Rendering Works

`locals.template.tf` does two passes:

1. **Substitution** — a regex finds every `${name}` (name restricted to `[a-zA-Z0-9]+`), wraps it in a `~~~` split marker, splits the file, and replaces each placeholder segment with the matching value from `var.parameters`. The `${` sequence is built with `join` so Terraform does not interpolate it in the HCL source.
2. **Decoding** — the format is `var.format` if set, otherwise derived from the file extension (`yaml`/`yml` → Yaml, `json` → Json, `tfvars` → Tfvars, anything else → Text). The joined string is decoded accordingly; Text returns the string as-is.

Behaviour to keep in mind:

- Placeholders with `_`, `-` or other characters are not matched and stay in the output literally.
- Placeholders without a matching parameter are collected in `local.missing_parameters`. The precondition on `output.result` fails and lists them; decoding is skipped in that case so a decode error cannot hide the real cause.
- Parameter values must be strings/numbers/bools; a validation on `var.parameters` rejects lists and maps.
- Substitution runs before decoding and values are not escaped, so they can break the target syntax (e.g. quotes or `:` in YAML).
- Extension matching is case-insensitive.
- Any literal `~~~` in the file is silently removed, because it is used as the internal split marker.

## Tests

Tests use the native framework with `command = plan` (the module has no resources). They point `file` at `examples/<format>/file.*`, so changing an example template changes test expectations. Edge cases use dedicated templates in `tests/fixtures/` (`tests/behaviour.tftest.hcl`). See the `terraform-tests` skill for conventions.

## Skills

Project skills live in `.claude/skills/`:

- `git-commit-conventions` — commit message rules (no attribution trailers, commits on `master`)
- `release` — tagging a new `vX.Y.Z` version for the Registry
- `terraform-tests` — writing and running the `.tftest.hcl` suite
