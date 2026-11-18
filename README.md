# lifo9/tap

A [Homebrew](https://brew.sh) tap with one cask:
[Quick Access for Bitwarden](https://github.com/lifo9/quick-access-for-bitwarden), a
Spotlight-style panel for macOS that searches the Bitwarden vault and copies values.

## Install

```sh
brew install --cask lifo9/tap/quick-access-for-bitwarden
```

Write the name in full. Since version 6, Homebrew only loads a tap that is not its own after it
has been trusted, and installing a cask by its full name trusts that one cask and nothing else
of the tap.

In a `Brewfile`:

```ruby
cask "lifo9/tap/quick-access-for-bitwarden", trusted: true
```

The app is for Apple silicon Macs with macOS 15 or later. It is a companion to the Bitwarden
desktop app, which has to be running and logged in, with **Unlock with Touch ID** switched on.

## How the cask follows the app

Once a day `.github/workflows/update.yml` looks at the app's newest release. When the cask is
behind, it downloads the disk image, checks its
[provenance attestation](https://docs.github.com/en/actions/concepts/security/artifact-attestations)
(the image must have been built by the app's release workflow, from its `main` branch, on a
GitHub runner), runs the checks below and commits the new version and checksum. A disk image
that fails any of this is not passed on.

`gh workflow run update.yml --repo lifo9/homebrew-tap` does the same at once.

## Checks

`scripts/check-casks.sh <tap name>` runs `brew style`, `brew audit --cask --strict --online`,
and installs and uninstalls each cask. CI runs it on every push and pull request, on a macOS
runner. It needs the checkout linked into Homebrew as the tap, which
[Homebrew's setup action](https://github.com/Homebrew/actions/tree/main/setup-homebrew) does.

## License

[MIT](LICENSE.md).

Bitwarden is a trademark of Bitwarden, Inc. It is used here only to name the software the cask
installs a companion for.
