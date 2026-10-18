#!/usr/bin/env bash
#
# Regenerates img/opengraph.png (the link-preview image) from a screenshot of index.html.
#
# Usage: scripts/update-opengraph.sh
#
# Requires Google Chrome or Chromium; set $CHROME to use a specific binary. If oxipng, optipng, or ImageMagick is
# installed, it's used to strip metadata and shrink the PNG. The page and its fonts are loaded from local files, so no
# internet connection is needed and Google Analytics doesn't load (it only does on santi.uy).
#
# The size must match the og:image:width/height meta tags in index.html.

set -euo pipefail

readonly WIDTH=1200
readonly HEIGHT=630

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly repo_root
readonly page="$repo_root/index.html"
readonly output="$repo_root/img/opengraph.png"

find_chrome() {
  if [[ -n "${CHROME:-}" ]]; then
    echo "$CHROME"
    return
  fi

  local candidate
  for candidate in google-chrome google-chrome-stable chromium chromium-browser chrome; do
    if command -v "$candidate" >/dev/null; then
      command -v "$candidate"
      return
    fi
  done

  candidate="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
  if [[ -x "$candidate" ]]; then
    echo "$candidate"
    return
  fi

  echo "Error: Chrome/Chromium not found. Install it or set \$CHROME to its path." >&2
  exit 1
}

chrome="$(find_chrome)"
readonly chrome

tmp_dir="$(mktemp -d)"
readonly tmp_dir
trap 'rm -rf "$tmp_dir"' EXIT

readonly screenshot="$tmp_dir/opengraph.png"

# - A throwaway profile avoids clashing with an already-running Chrome.
# - The virtual time budget gives the web fonts time to load before the screenshot is taken.
"$chrome" \
  --headless=new \
  --disable-gpu \
  --no-first-run \
  --no-default-browser-check \
  --user-data-dir="$tmp_dir/profile" \
  --hide-scrollbars \
  --force-device-scale-factor=1 \
  --window-size="$WIDTH,$HEIGHT" \
  --virtual-time-budget=10000 \
  --screenshot="$screenshot" \
  "file://$page" \
  >/dev/null 2>&1

if [[ ! -s "$screenshot" ]]; then
  echo "Error: Chrome didn't produce a screenshot." >&2
  exit 1
fi

if command -v oxipng >/dev/null; then
  oxipng --quiet --opt 4 --strip safe "$screenshot"
elif command -v optipng >/dev/null; then
  optipng -quiet -o5 -strip all "$screenshot"
elif command -v magick >/dev/null; then
  magick "$screenshot" -strip "$screenshot"
elif command -v convert >/dev/null; then
  convert "$screenshot" -strip "$screenshot"
fi

mv "$screenshot" "$output"

echo "Updated ${output#"$repo_root/"} (${WIDTH}x${HEIGHT}, $(wc -c <"$output" | tr -d ' ') bytes)."
