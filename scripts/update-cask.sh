#!/usr/bin/env bash
# Points the cask at the newest release of the app and commits that, when the cask is behind.
# Prints the version it moved to, or nothing when the cask was current.
#
# Needs an authenticated `gh` (GH_TOKEN) and the checkout linked into Homebrew as the tap.
set -euo pipefail

tap_name="${1:?usage: update-cask.sh <tap name, such as lifo9/tap>}"
app_repository="lifo9/quick-access-for-bitwarden"
release_workflow="${app_repository}/.github/workflows/release.yml"
cask_token="quick-access-for-bitwarden"
cask_file="Casks/${cask_token}.rb"

# The newest release that is neither a draft nor a prerelease.
latest_tag="$(gh release view --repo "${app_repository}" --json tagName --jq .tagName)"
# The version is written into a Ruby file that Homebrew runs: nothing but a plain version may pass.
if [[ ! "${latest_tag}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]
then
  echo "error: the newest release has the unexpected tag '${latest_tag}'" >&2
  exit 1
fi
latest_version="${latest_tag#v}"

current_version="$(sed -nE 's/^  version "([^"]+)"$/\1/p' "${cask_file}")"
if [[ -z "${current_version}" ]]
then
  echo "error: no version found in ${cask_file}" >&2
  exit 1
fi
if [[ "${latest_version}" == "${current_version}" ]]
then
  exit 0
fi

download_directory="$(mktemp -d)"
trap 'rm -rf "${download_directory}"' EXIT
gh release download "${latest_tag}" --repo "${app_repository}" --pattern '*.dmg' --dir "${download_directory}" >&2
disk_images=("${download_directory}"/*.dmg)
if [[ ${#disk_images[@]} -ne 1 || ! -f "${disk_images[0]}" ]]
then
  echo "error: release ${latest_tag} does not carry exactly one disk image" >&2
  exit 1
fi

# A release can be edited by whoever gets hold of the repository. The cask only moves to a disk
# image that the app's release workflow built from its main branch on a GitHub runner, which the
# image's provenance attestation proves.
gh attestation verify "${disk_images[0]}" \
  --repo "${app_repository}" \
  --signer-workflow "${release_workflow}" \
  --source-ref refs/heads/main \
  --deny-self-hosted-runners >&2

disk_image_sha256="$(shasum -a 256 "${disk_images[0]}" | cut -d ' ' -f 1)"

# Audit and style are left to check-casks.sh, which also installs the cask.
brew bump-cask-pr --write-only --commit --no-audit --no-style \
  --version "${latest_version}" --sha256 "${disk_image_sha256}" "${tap_name}/${cask_token}" >&2

echo "${latest_version}"
