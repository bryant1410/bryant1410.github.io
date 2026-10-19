#!/usr/bin/env bash
#
# Runs all code, markup, workflow, and accessibility linters across the repository.
#
# Usage: scripts/lint.sh
#
# Checks:
#   1. ShellCheck (scripts/*.sh)
#   2. html-validate (index.html, 404.html, cv.html)
#   3. markdownlint (README.md)
#   4. actionlint (.github/workflows/*.yml)
#   5. pa11y accessibility audit (index.html, 404.html)
#

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly repo_root
cd "$repo_root"

echo "=== [1/5] ShellCheck ==="
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck scripts/*.sh
  echo "✓ ShellCheck passed."
else
  echo "⚠ shellcheck not found in PATH (install via apt or brew). Skipping."
fi

echo ""
echo "=== [2/5] html-validate ==="
npx --yes html-validate index.html 404.html cv.html
echo "✓ html-validate passed."

echo ""
echo "=== [3/5] markdownlint ==="
npx --yes markdownlint-cli README.md
echo "✓ markdownlint passed."

echo ""
echo "=== [4/5] actionlint ==="
if command -v actionlint >/dev/null 2>&1; then
  actionlint -color
  echo "✓ actionlint passed."
elif command -v go >/dev/null 2>&1; then
  go run github.com/rhysd/actionlint/cmd/actionlint@latest -color
  echo "✓ actionlint passed."
else
  echo "⚠ actionlint or go not found in PATH. Skipping."
fi

echo ""
echo "=== [5/5] pa11y (accessibility) ==="
npx --yes pa11y "file://$repo_root/index.html"
npx --yes pa11y "file://$repo_root/404.html"
echo "✓ pa11y passed."

echo ""
echo "✨ All linters passed successfully!"
