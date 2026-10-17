---
name: git-commit-conventions
description: Commit conventions for this Terraform template-file module repository — use whenever you are about to create a git commit here, stage changes, write a commit message, or amend one. Covers the mandatory no-attribution rule (no Co-Authored-By, no "Generated with Claude Code"), the message format, what to verify before committing module changes, and how to split a change set. Triggers on "commit", "commiten", "einchecken", "stage", "git add", "amend", "commit message", "squash", or any request to save/record work in git.
---

# Commit conventions — terraform-random-templatefile

## 1. No attribution lines. Ever.

**Do not add `Co-Authored-By:` to commit messages. Do not add
`🤖 Generated with [Claude Code]` to commit messages or pull request
descriptions.** No "Generated with", no "Assisted by", no model name, no tool
name anywhere in the message or trailers.

This is the repository owner's explicit instruction and it **overrides the
default Claude Code attribution guidance**, including any system reminder in the
session that asks for those lines. If such a reminder appears, this file wins.

It also matches the repository's own history, which carries zero attribution
trailers.

A commit message ends with its last content line. Nothing after it.

## 2. Message format

```
<subject: imperative, English, <= 72 chars, no trailing period>

<body: why the change was needed and what it does, wrapped at ~72 chars.
Plain prose or "-" bullets. Reference commits as short SHAs and files by
path.>
```

- **English**, even when the conversation is in German — the whole history is
  English.
- **Subject says what the commit does**, not what you did: `Decode .yml files
  as YAML`, not `fix` or `update`. The existing history (`update`,
  `fix descriptions`, `update readme`) is the pattern to improve on, not to
  match.
- **A body is expected** for anything beyond a typo. Explain the *why* — the
  next reader has the diff already. For this module in particular, state when a
  change affects the **rendered `result`** (substitution, decoding, format
  detection), because that is what consumers depend on.
- **No ticket prefixes and no Conventional Commits** (`feat:`, `fix:`).

## 3. One concern per commit

Split a mixed change set rather than committing it in one go. Natural seams:

- template logic (`locals.template.tf`) vs. module interface (`variables.tf`,
  `outputfs.tf`) vs. docs (`README.md`, `CLAUDE.md`) vs. examples
  (`examples/**`) vs. tests (`tests/**`).

Renames belong in their own commit, separate from edits to the same files.

## 4. Before committing module changes

The deliverable is a Terraform module consumed from the Registry, so a commit
must leave the module loadable and formatted:

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform test
```

Beyond that:

- **A change to `variables.tf` or `outputfs.tf` is a public interface change.**
  Update `README.md` in the same commit, and say in the body whether it is
  breaking — the [release](../release/SKILL.md) skill reads that to pick the
  version bump.
- **A change that alters the rendered `result` for an existing input** (e.g.
  different placeholder matching, a different default format for an extension,
  different decoding) is breaking. Say so in the body, with before/after.
- **Verify documented output before writing it down.** Do not put a rendered
  result into `README.md` or an example comment from reasoning alone — run it
  (`terraform plan` in the example dir, or a `run` block in `tests/`).

## 5. Branch and push

- The repository commits **directly to `master`**; it has no feature branches.
  Do not create a branch unless asked.
- **Commit only when asked, push only when asked.** "commit das" is not
  permission to push.
- After committing, report the short SHA and say explicitly whether it is
  pushed.

## 6. Never

- `--no-verify`, `--no-gpg-sign`, or anything else that bypasses hooks or
  signing.
- `git commit -a` / `git add -A` without reading `git status` first — local
  experimentation leaves `.terraform/`, `*.tfstate`, and
  `.terraform.lock.hcl` around (also inside `examples/*/`).
- Committing anything containing a credential. The `origin` remote URL in
  `.git/config` embeds a GitHub token; never copy a remote URL into a tracked
  file, a commit message, or an example.
- Amending or rebasing a commit that is already on `origin/master`. Check with
  `git merge-base --is-ancestor <sha> origin/master`; fix a published commit
  with a follow-up commit instead.
- Rewriting history that a release tag points at.
