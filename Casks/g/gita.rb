cask "gita" do
  version "0.3.0"
  sha256 "c0f8875739880075dd90fa84a5a871c6a665552772d88a7e4446a993b2ed8203"

  url "https://github.com/clever-mechanisms/gita/releases/download/v#{version}/Gita-#{version}-macos.zip",
      verified: "github.com/clever-mechanisms/gita/"
  name "Gita"
  desc "Native Git client built around repository history"
  homepage "https://getgita.app/"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: ">= :sonoma"

  app "Gita.app"

  zap trash: [
    "~/Library/Application Support/dev.clevermechanisms.Gita",
    "~/Library/Caches/dev.clevermechanisms.Gita",
    "~/Library/HTTPStorages/dev.clevermechanisms.Gita",
    "~/Library/Preferences/dev.clevermechanisms.Gita.plist",
    "~/Library/Saved Application State/dev.clevermechanisms.Gita.savedState",
  ]
end
