#!/usr/bin/env bash
# One-time: move Hive files that were created at ~/Documents/*.hive before
# lib/hive_storage.dart used the vogue_vault/hive subdirectory.
set -euo pipefail
DOC="${HOME}/Documents"
DEST="${DOC}/vogue_vault/hive"
mkdir -p "$DEST"
shopt -s nullglob
for f in "$DOC"/*.hive "$DOC"/*.lock; do
  [[ -e "$f" ]] || continue
  echo "Moving $(basename "$f") -> vogue_vault/hive/"
  mv -f "$f" "$DEST/"
done
echo "Done. Expected location for new data: $DEST"
