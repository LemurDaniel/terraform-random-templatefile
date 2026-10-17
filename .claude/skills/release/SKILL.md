---
name: release
description: Cut a new version of this Terraform template-file module and tag it so the Terraform Registry picks it up. Use when the user wants to release, publish, cut, bump, or tag a new module version ("release 1.1.0", "neue version", "bump patch", "tag a release", "publish to registry"), or asks which version is current / what changed since the last tag.
---

# Releasing a new module version

The Terraform Registry has no "publish" API — **it discovers versions purely from git tags**.
Cutting a release means: validate, tag with a semver tag, push the tag.

> **Any commit this process creates follows
> [git-commit-conventions](../git-commit-conventions/SKILL.md) — read it before committing.**
> No `Co-Authored-By` or "Generated with Claude Code" trailers, English imperative subject,
> a body explaining the why. The same applies to the tag annotation and GitHub release notes.

## Tagging rules the Registry enforces

- The tag must be **semver** `x.y.z`. This repo uses the **`v` prefix** (`v1.0.0` … `v1.0.3`)
  — keep it.
- Pre-release tags (`v1.2.0-rc1`) never resolve as `latest`. Only cut one if asked.
- The tag must be pushed; a local tag does nothing.
- Never move or delete a published tag. Fix a mistake by cutting the next patch.

## Steps

### 1. Current version

```bash
git fetch --tags --prune
git tag --sort=-v:refname | head -5
```

Bump from the **highest** tag.

### 2. Decide the bump

If the user named a version or level, use it. Otherwise inspect and propose one with a reason:

```bash
git log <last-tag>..HEAD --oneline
git diff <last-tag>..HEAD --stat
```

The public interface is `variables.tf` (`file`, `parameters`, `format`) and `outputfs.tf`
(`result`):

- **major** — a variable removed/renamed/made required/typed stricter, `result` removed or its
  shape changed, an allowed `format` value dropped, or the rendered `result` changes for an
  input that used to render differently (placeholder syntax, extension → format mapping,
  decoding behaviour).
- **minor** — a new optional variable, a new output, a new supported format or extension,
  anything that leaves existing configs rendering the same.
- **patch** — bug fixes, docs, examples, tests, formatting.

When unsure between minor and major, ask. Read commit bodies for "breaking" notes first; fall
back to the diff of `variables.tf`, `outputfs.tf` and `locals.template.tf`.

### 3. Test suite — mandatory gate

```bash
terraform init -backend=false
terraform test
```

- **Green** → continue.
- **Red** → stop, report the failing `run` blocks, do not tag.
- **Fails before any assertion** (init/variable error) → the suite is broken, not the module.
  Say the release is **unverified** and ask whether to proceed. Never let that read as a pass.

See [terraform-tests](../terraform-tests/SKILL.md).

### 4. Remaining checks

```bash
git status --porcelain                  # must be empty
git rev-parse --abbrev-ref HEAD         # must be master
git log origin/master..HEAD --oneline   # must be empty — push before tagging
terraform fmt -check -recursive
terraform validate
```

### 5. Docs and constraints

- `README.md` must match `variables.tf` / `outputfs.tf`.
- The `source` address in `README.md` and `examples/**/main.tf` must be the actual Registry
  address and consistent everywhere (check for `templatefile/random` vs `template/random`).
- Version constraints in docs/examples are **minimums** (`>= x.y.z`); raise them when the docs
  rely on the version being cut. Do not convert to `~>`.

Commit such changes per [git-commit-conventions](../git-commit-conventions/SKILL.md) and push
before tagging.

### 6. Tag and push

```bash
git tag -a v1.0.4 -m "v1.0.4

- <change one>
- <change two>"

git push origin v1.0.4
```

Push the tag by name, never `--tags`.

### 7. Confirm

- The Registry picks the tag up via webhook, usually within minutes.
- Optionally mirror with `gh release create v1.0.4 --notes "..."` if `gh` is available — not
  required for the Registry.
- Report the version, the bump level with its reason, and anything still open.
