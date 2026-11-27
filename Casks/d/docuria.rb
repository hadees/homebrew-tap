cask "docuria" do
  version "0.7,102"
  sha256 "ab8f46888d9bf34e76543c1e638b6f96e81dc39553fbd7f302c831b1b28b590e"

  url "https://updates.docuria.app/Docuria-#{version.csv.first}-Build-#{version.csv.second}.zip"
  name "Docuria"
  desc "Document reader with read-aloud, speed reading, semantic search and compare"
  homepage "https://docuria.app/"

  livecheck do
    url "https://updates.docuria.app/appcast.xml"
    strategy :sparkle
  end

  auto_updates true
  depends_on arch: :arm64
  depends_on macos: :tahoe

  app "Docuria.app"

  zap trash: [
    "~/Library/Application Support/com.amplifyinteractions.docuria",
    "~/Library/Caches/com.amplifyinteractions.docuria",
    "~/Library/HTTPStorages/com.amplifyinteractions.docuria",
    "~/Library/Preferences/com.amplifyinteractions.docuria.plist",
    "~/Library/Saved Application State/com.amplifyinteractions.docuria.savedState",
  ]
end
