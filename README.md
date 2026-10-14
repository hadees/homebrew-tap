# hadees/tap

Casks that Homebrew's own tap no longer installs (most were disabled on
2026-09-01 for failing the Gatekeeper check) and that are still in use here.

```ruby
# Brewfile
tap "hadees/tap"
cask "hadees/tap/xpra"
```

| Cask | Notes |
| --- | --- |
| `xpra` | notarized; `xpra` on PATH is a wrapper, not a symlink (the launcher finds its bundle from the path it was run by) |
| `deluge` | unsigned, Intel only (Rosetta) |
| `hakuneko` | unsigned, Intel only (Rosetta) |

## Quarantine

Each cask removes `com.apple.quarantine` from **its own app** after install,
so an unsigned app opens without System Settings → Open Anyway. Nothing
outside that app is touched. Adding a cask here is deciding to trust it.

## Where updates come from

Every cask file here is this tap's own copy; nothing is read from anywhere
else at install time. Two scheduled jobs propose changes as pull requests, and
nothing merges on its own:

- **`brew bump`** (`autobump.yml`, daily) reads each cask's `livecheck`
  against upstream directly.
- **open-tap sync** (`open-tap-sync.yml`, weekly) compares each cask *that is
  already here* with the same file in
  [open-tap/homebrew-casks](https://github.com/open-tap/homebrew-casks).
  The PR title says `version only`, or `REVIEW: …` when anything other than
  `version`/`sha256` changed (a url, an install step), or when a checksum
  moved without a version change.

These copies differ from open-tap's on purpose — the quarantine step targets
`{{appdir}}/<App>.app` (open-tap's `{{staged_path}}` only reaches a symlink, so
files inside the app stay quarantined) and `xpra` uses `command_wrapper` — so
a sync PR that would undo either is a `REVIEW` one; close it. A closed one is not reopened until open-tap changes that file again.
