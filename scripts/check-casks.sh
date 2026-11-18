#!/usr/bin/env bash
# Checks every cask of the tap the way Homebrew treats it: style, audit, then a real install and
# uninstall. The audit downloads the artifact and, among other things, refuses one that Gatekeeper
# would not open.
#
# The checkout has to be linked into Homebrew as the tap and trusted, which Homebrew's setup action
# does in CI.
set -euo pipefail

tap_name="${1:?usage: check-casks.sh <tap name, such as lifo9/tap>}"

brew style "$tap_name"

for cask_file in Casks/*.rb; do
    cask_name="$tap_name/$(basename "$cask_file" .rb)"
    brew audit --cask --strict --online "$cask_name"
    brew install --cask "$cask_name"
    brew uninstall --cask "$cask_name"
done
