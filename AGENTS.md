# lifo9/tap

A Homebrew tap. `Casks/` holds one cask, for
[Quick Access for Bitwarden](https://github.com/lifo9/quick-access-for-bitwarden).
[README.md](README.md) says how it is installed and how it follows the app's releases.

## Checks

`scripts/check-casks.sh <tap name>` is the whole check: style, audit, install, uninstall. It only
works where the checkout is linked into Homebrew as the tap, so it runs in CI
(`.github/workflows/ci.yml`), not on a Mac whose taps are read-only. Locally, check that the
scripts parse (`bash -n scripts/*.sh`) and let CI do the rest on a pull request.

`brew style` also holds the shell scripts of a tap to Homebrew's shell style, with shellcheck
and shfmt: two spaces, `then` and `do` on their own line, braces around every variable.
`nix shell nixpkgs#shellcheck -c shellcheck --enable=require-variable-braces scripts/*.sh`
catches the braces before CI does.

## Rules

- The cask's `version` and `sha256` are written by `.github/workflows/update.yml`, which commits
  to `main` itself after running the checks. Everything else changes through a pull request.
- `scripts/update-cask.sh` finds the version with a pattern that expects `version "…"` on a line
  of its own, indented by two spaces. Keep the cask in that form.
- The updater passes on only a disk image whose provenance attestation names the app's release
  workflow and its `main` branch. If the app's workflow file is renamed, change
  `release_workflow` in the script with it, or every update fails.
- GitHub switches a scheduled workflow off after 60 days without activity in the repository and
  sends a mail about it. `gh workflow enable update.yml` switches it back on.
