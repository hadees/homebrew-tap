#!/bin/bash
# For each cask this tap carries, compare it with the same file in
# open-tap/homebrew-casks and open (or refresh) a pull request when they
# differ. Only casks already here are synced: adding one is done by hand.
#
# Nothing merges on its own. The PR title says whether only `version` and
# `sha256` moved, or whether anything else did (a url, an install step, a new
# stanza) — that second kind is what reading the diff is for.
#
#   open-tap-sync.sh             sync (CI: needs GH_TOKEN and a checkout)
#   open-tap-sync.sh self-test   check the verdict logic
set -euo pipefail

upstream=https://raw.githubusercontent.com/open-tap/homebrew-casks/main

# verdict OLD NEW: prints "version only" or "REVIEW: <why>".
verdict() {
  local changed
  changed=$(diff "$1" "$2" | grep '^[<>]' || true)
  local digest='"[0-9a-f]{64}",?'
  local other
  other=$(grep -vE "^[<>][[:space:]]*(version \"[^\"]*\"|sha256 $digest|(sha256 )?(arm|intel): +$digest)[[:space:]]*\$" <<< "$changed" || true)
  if [ -n "$other" ]; then
    echo "REVIEW: more than version and sha256 changed"
  elif ! grep -qE '^[<>][[:space:]]*version ' <<< "$changed"; then
    echo "REVIEW: sha256 changed without a version change"
  else
    echo "version only"
  fi
}

if [ "${1:-}" = self-test ]; then
  d=$(mktemp -d)
  hex() { printf '%064d' "$1"; }
  printf 'cask "x" do\n  version "1.0"\n  sha256 "%s"\n  url "https://example.com/x-#{version}.dmg"\nend\n' "$(hex 1)" > "$d/a"
  sed "s/1\.0/1.1/; s/$(hex 1)/$(hex 2)/" "$d/a" > "$d/bump"
  sed "s/$(hex 1)/$(hex 2)/" "$d/a" > "$d/swap"
  sed "s/1\.0/1.1/; s/$(hex 1)/$(hex 2)/; s/example\.com/example.net/" "$d/a" > "$d/url"
  [ "$(verdict "$d/a" "$d/bump")" = "version only" ]
  [ "$(verdict "$d/a" "$d/swap")" = "REVIEW: sha256 changed without a version change" ]
  [ "$(verdict "$d/a" "$d/url")" = "REVIEW: more than version and sha256 changed" ]
  echo "self-test: ok"
  exit 0
fi

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

for path in Casks/*/*.rb; do
  cask=$(basename "$path" .rb)
  branch="open-tap/$cask"
  theirs=$(mktemp)
  if ! curl -fsSL "$upstream/$path" -o "$theirs"; then
    echo "::notice::$cask: not in open-tap (or unreachable); kept as is"
    continue
  fi
  git checkout -q main
  cmp -s "$path" "$theirs" && continue
  # Already proposed (open, or closed as unwanted): wait for open-tap to move.
  if git fetch -q origin "$branch" 2>/dev/null &&
    git show "FETCH_HEAD:$path" 2>/dev/null | cmp -s - "$theirs"; then
    continue
  fi

  v=$(verdict "$path" "$theirs")
  # shellcheck disable=SC2016 # the backticks are Markdown
  body=$(printf 'open-tap/homebrew-casks changed `%s`.\n\nVerdict: **%s**\n\n```diff\n%s\n```\n' \
    "$path" "$v" "$(diff -u "$path" "$theirs" | tail -n +3 || true)")
  git checkout -q -B "$branch" main
  cp "$theirs" "$path"
  git commit -q -am "$cask: sync from open-tap/homebrew-casks"
  git push -q -f origin "$branch"
  title="$cask: sync from open-tap ($v)"
  if [ "$(gh pr view "$branch" --json state -q .state 2>/dev/null || true)" = OPEN ]; then
    gh pr edit "$branch" --title "$title" --body "$body"
  else
    gh pr create --head "$branch" --base main --title "$title" --body "$body"
  fi
done
git checkout -q main
