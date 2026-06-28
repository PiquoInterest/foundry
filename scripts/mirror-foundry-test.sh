#!/usr/bin/env bash
# Mirror every git-tracked file into foundry_test/, preserving directory paths.
#
# Purpose: produce a 1:1 duplicate of the committed source tree that the Codex
# Cloud security scanner can scan as a self-contained subtree, while the real
# tree keeps building (workspace members are explicit paths, so the copies under
# foundry_test/crates/... are never compiled).
#
# Refresh workflow:
#   git switch latest && git pull        # pull the original/upstream code
#   git switch master && git merge latest
#   ./scripts/mirror-foundry-test.sh     # regenerate the mirror
#   git add foundry_test && git commit -m "chore: refresh foundry_test mirror"
#
# ponytail: drives off `git ls-files` (committed tree only) and streams through
# tar in a single pass; refresh = rm -rf + re-run, so it is idempotent.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

DEST=foundry_test

rm -rf "$DEST"
mkdir -p "$DEST"

# Exclude the mirror itself so re-runs don't nest foundry_test/foundry_test/...
git ls-files -z | grep -zv "^$DEST/" | tar --null -T - -cf - | tar -xf - -C "$DEST"

echo "Mirrored $(git ls-files | grep -cv "^$DEST/") tracked files into $DEST/"
