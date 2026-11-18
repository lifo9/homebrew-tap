cask "quick-access-for-bitwarden" do
  version "0.1.0"
  sha256 "b4b2d52edc7715474a728afdf9115acbe10bc736f6c96dc161af001e1fd386a4"

  url "https://github.com/lifo9/quick-access-for-bitwarden/releases/download/v#{version}/Quick-Access-for-Bitwarden-#{version}.dmg"
  name "Quick Access for Bitwarden"
  desc "Spotlight-style panel to search the Bitwarden vault and copy values"
  homepage "https://github.com/lifo9/quick-access-for-bitwarden"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: :sequoia

  app "Quick Access for Bitwarden.app"

  uninstall quit: "dev.filo.quick-access-for-bitwarden"

  zap trash: "~/Library/Preferences/dev.filo.quick-access-for-bitwarden.plist"

  caveats <<~EOS
    #{token} is a companion to the Bitwarden desktop app, which has to be
    running and logged in, with "Unlock with Touch ID" switched on in its settings.
  EOS
end
