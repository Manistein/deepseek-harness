#!/bin/sh
# NOT `#!/usr/bin/env bash`: `env bash` resolves along PATH and can land on the
# WSL launcher (C:\Windows\System32\bash.exe), where Windows git is unreachable,
# and minimal git-for-windows builds (GitHub Desktop's bundled git) ship no bash
# at all. `/bin/sh` resolves inside the running MSYS runtime on Windows and
# natively on Unix, so the script stays POSIX sh and runs wherever lefthook does.
# Vendoring discipline, mechanized: any staged change under vendor/*/src or a
# vendored bin.js must come with a vendor/README.md change in the same commit
# (the manifest's local-modification log is the contract — see vendor/README.md).
set -eu

staged=$(git diff --cached --name-only)

vendor_src_changed=$(echo "$staged" | grep -E '^vendor/[^/]+/(src/|bin\.js)' || true)
manifest_changed=$(echo "$staged" | grep -x 'vendor/README.md' || true)

if [ -n "$vendor_src_changed" ] && [ -z "$manifest_changed" ]; then
  echo 'vendor manifest guard: vendored SOURCE changed without updating vendor/README.md:'
  echo "$vendor_src_changed" | sed 's/^/  /'
  echo 'Log the modification in vendor/README.md ("Local modifications") and stage it.'
  exit 1
fi
