#!/usr/bin/env bash
#
# Runs all code, markup, workflow, and accessibility linters across the repository.
#
# Usage: scripts/lint.sh
#
# Checks:
#   1. ShellCheck (scripts/*.sh)
#   2. html-validate (index.html, 404.html, cv.html)
#   3. JavaScript quote consistency (index.html, 404.html, cv.html)
#   4. markdownlint (README.md)
#   5. actionlint (.github/workflows/*.yml)
#   6. pa11y accessibility audit (index.html, 404.html)
#

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly repo_root
cd "$repo_root"

echo "=== [1/6] ShellCheck ==="
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck scripts/*.sh
  echo "✓ ShellCheck passed."
else
  echo "⚠ shellcheck not found in PATH (install via apt or brew). Skipping."
fi

echo ""
echo "=== [2/6] html-validate ==="
npx --yes html-validate index.html 404.html cv.html
echo "✓ html-validate passed."

echo ""
echo "=== [3/6] JavaScript quote consistency ==="
python3 - <<'EOF'
import re, sys

errors = 0
for path in ["index.html", "404.html", "cv.html"]:
    with open(path, encoding="utf-8") as f:
        content = f.read()
    scripts = re.findall(r"<script>(.*?)</script>", content, re.DOTALL)
    for script in scripts:
        code = re.sub(r"/\*.*?\*/", "", script, flags=re.DOTALL)
        for line in code.splitlines():
            line_code = re.sub(r"//.*$", "", line).strip()
            line_code = re.sub(r'"(?:\\.|[^"\\])*"', '""', line_code)
            line_code = re.sub(r'/(?:\\.|[^/\\\n])+/[a-z]*', '', line_code)
            if "'" in line_code:
                print(f"{path}: expected double quotes, found single quote in: {line.strip()}")
                errors += 1

if errors:
    sys.exit(1)
EOF
echo "✓ JavaScript quote consistency passed."

echo ""
echo "=== [4/6] markdownlint ==="
npx --yes markdownlint-cli README.md
echo "✓ markdownlint passed."

echo ""
echo "=== [5/6] actionlint ==="
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
echo "=== [6/6] pa11y (accessibility) ==="
npx --yes pa11y --config "$repo_root/.pa11y.json" "file://$repo_root/index.html"
npx --yes pa11y --config "$repo_root/.pa11y.json" "file://$repo_root/404.html"
echo "✓ pa11y passed."

echo ""
echo "✨ All linters passed successfully!"
