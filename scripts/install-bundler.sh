#!/bin/bash

set -euxo pipefail

GEMFILE_LOCK="Gemfile.lock"

if [ -f "${GEMFILE_LOCK}" ]; then

  extract_version() { tr -cd "[:digit:]\."; }
  BUNDLED_WITH=$(tail -n 1 "${GEMFILE_LOCK}" | extract_version)
  unset -f extract_version
  GEM="gem"
  if command -v rbenv &> /dev/null; then
    GEM="rbenv exec gem"
  fi
  $GEM install bundler -v "${BUNDLED_WITH}" -N --force
  bundle "_${BUNDLED_WITH}_" install
fi
