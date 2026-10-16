# CLAUDE.md

## Repository purpose

archetype: tooling

`hadees/tap`, a public Homebrew tap. It is an overlay: this repo keeps its
own copy of each cask that homebrew/cask stopped installing, and two scheduled
bots propose updates to those copies as PRs. README.md explains the casks, the
quarantine step and where updates come from. Nothing is read from anywhere
else at install time.

### Deviations from the ICA repo standard (scaffold-repo)

The audit waives what an external owner, the cask DSL and `brew test-bot`
make moot (public repo, Dependabot, no Ruby toolchain, no JUnit). It still
reports these two, and both are deliberate:

- `lint/hook-yamllint`: the only YAML is the workflows and `dependabot.yml`,
  which actionlint and the schema hooks cover.
- `github/required-checks`: no required status check on `main` (operator's
  choice). Both bots open PRs with `GITHUB_TOKEN`, and test-bot runs on those
  PRs only after someone approves the run (the PR's Checks tab, "Approve and
  run"). An unapproved run expires and fails with "required approval but was
  not approved". So the bots check their own changes before opening a PR:
  `brew bump` audits and styles, and `open-tap-sync.sh` runs `brew style` and
  `brew audit` and puts the result in the PR.

## Contributing

- Commits and PRs follow the personal git conventions (hadees-skills
  `git-conventions`): an emoji plus Conventional Commits subject, which
  `.githooks/check-subject.sh` checks as a commit-msg hook. Use a branch and PR
  for anything with more than one moving part.
- Merge with a merge commit: `gh pr merge <N> --merge --delete-branch`.
- Adding a cask is deciding to trust it (README, "Quarantine"). Remove the
  quarantine attribute from `{{appdir}}/<App>.app`, never from
  `{{staged_path}}`.
- A `REVIEW:` sync PR that would undo a deliberate difference from open-tap
  gets closed, not merged. Its branch is what stops it being reopened, so
  leave the branch in place.

## Toolchain (pinned per-project)

`.tool-versions` pins shellcheck and actionlint (asdf/mise). `brew style` and
`brew audit` come from the local Homebrew, with this tap tapped.

## Tests

- `brew test-bot --only-tap-syntax` in `tests.yml` (macOS and Linux) is the
  cask test suite. To run it locally: `brew style Casks` and
  `brew audit --cask --tap hadees/tap`.
- `.github/open-tap-sync.sh self-test` checks the sync verdict logic.

## Lint / format / type-check

`uvx prek install` once, then `uvx prek run --all-files`. Hooks: shellcheck,
shfmt (reads `.editorconfig`), actionlint, zizmor, `brew style` on casks,
markdownlint, typos, gitleaks, editorconfig-checker.

## CI

- `tests.yml`: test-bot on push to main and on PRs, plus the sync script's
  self-test and shellcheck.
- `autobump.yml`: `brew bump`, daily.
- `open-tap-sync.yml`: syncs from open-tap, weekly.
- Dependabot keeps the actions current, with SHA pins.
