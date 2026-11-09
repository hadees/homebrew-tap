cask "xpra" do
  arch arm: "arm64", intel: "x86_64"

  version "6.5.6,0"
  sha256 arm:   "0446e0ba03cb819ddbc2053c62c4b2abbee1a75c9807a9c86b9c752f0d908b00",
         intel: "8c42343fee4c3d683f99c612a7d6ab46d3cafb127b1e217d7e7abb251f4e9245"

  url "https://xpra.org/dists/MacOS/#{arch}/Xpra-#{arch}-#{version.csv.first}-r#{version.csv.second}.dmg"
  name "Xpra"
  desc "Screen and application forwarding system"
  homepage "https://github.com/Xpra-org/xpra/"

  livecheck do
    url "https://xpra.org/dists/MacOS/#{arch}/"
    regex(/href=.*?Xpra-#{arch}[._-]v?(\d+(?:\.\d+)+)(?:[._-]r(\d+))?\.dmg/i)
    strategy :page_match do |page, regex|
      page.scan(regex).map do |match|
        match[1] ? "#{match[0]},#{match[1]}" : match[0]
      end
    end
  end

  depends_on macos: :monterey

  app "Xpra.app"
  binary "#{appdir}/Xpra.app/Contents/MacOS/Xpra", target: "xpra"

  postflight_steps do
    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
  end

  zap delete: "/Library/Application Support/Xpra",
      trash:  [
        "~/Library/Application Support/Xpra",
        "~/Library/Saved Application State/org.xpra.xpra.savedState",
      ]
end
