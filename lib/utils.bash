#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-or-later
# shellcheck shell=bash

set -euo pipefail

TOOL_NAME="cobol"
TOOL_TEST="cobc --version"

# GnuCOBOL SourceForge download base URL
GNUCOBOL_RELEASES_URL="https://sourceforge.net/projects/gnucobol/files/gnucobol"

fail() {
  printf '%s\n' "$1" >&2
  exit 1
}

curl_opts=(-fsSL)

# Detect download utility
if command -v curl &>/dev/null; then
  download_cmd="curl"
elif command -v wget &>/dev/null; then
  download_cmd="wget"
else
  fail "Neither curl nor wget is available. Please install one of them."
fi

download() {
  local url="$1"
  local output="$2"

  if [[ "$download_cmd" == "curl" ]]; then
    curl "${curl_opts[@]}" -o "$output" "$url"
  else
    wget -q -O "$output" "$url"
  fi
}

download_stdout() {
  local url="$1"

  if [[ "$download_cmd" == "curl" ]]; then
    curl "${curl_opts[@]}" "$url"
  else
    wget -q -O - "$url"
  fi
}

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_all_versions() {
  # Fetch version list from SourceForge RSS feed (more reliable than HTML)
  # RSS contains entries like: /gnucobol/3.2/gnucobol-3.2.tar.gz
  # RC versions use format: gnucobol-3.2-rc1.tar.gz (with hyphen)
  # Only match clean version tarballs (not _bin, _win, -preview variants)
  download_stdout "https://sourceforge.net/projects/gnucobol/rss?path=/gnucobol" 2>/dev/null |
    grep -oE 'gnucobol-[0-9]+\.[0-9]+(\.[0-9]+)?(-rc[0-9]+)?\.tar\.(gz|xz|bz2)' |
    grep -v -E '(_bin|_win|preview)' |
    sed -E 's/gnucobol-([0-9]+\.[0-9]+(\.[0-9]+)?(-rc[0-9]+)?)\.tar\..*/\1/' |
    sort -u
}

get_version_folder() {
  local version="$1"
  # SourceForge organizes by major.minor version (without rc suffix)
  # e.g., 3.2-rc1 -> folder is 3.2, tarball is gnucobol-3.2-rc1.tar.gz
  printf '%s' "$version" | sed -E 's/(-rc[0-9]+)$//'
}

get_download_url() {
  local version="$1"
  local folder
  folder="$(get_version_folder "$version")"
  local tarball_name="gnucobol-${version}.tar.gz"

  # SourceForge download URL pattern
  printf '%s/%s/%s/download' "$GNUCOBOL_RELEASES_URL" "$folder" "$tarball_name"
}

get_fallback_download_url() {
  local version="$1"
  local folder
  folder="$(get_version_folder "$version")"
  local tarball_name="gnucobol-${version}.tar.xz"

  # Try .tar.xz as fallback
  printf '%s/%s/%s/download' "$GNUCOBOL_RELEASES_URL" "$folder" "$tarball_name"
}
