#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
python3 tests/hypr/parity.py
for file in hypr/*.lua; do luac -p "$file"; done
bash tests/hypr/ipc.sh
for file in bin/dots-focus-layout.sh; do
    bash -n "$file"
done
git diff --check
