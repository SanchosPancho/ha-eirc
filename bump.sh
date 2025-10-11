#!/usr/bin/env bash
set -euo pipefail

FILE="custom_components/eirc/manifest.json"
NEXT_VERSION="${1:?Usage: $0 <next_version>}"

if command -v jq >/dev/null 2>&1; then
  tmp="$(mktemp)"
  jq --arg v "$NEXT_VERSION" '.version = $v' "$FILE" > "$tmp"
  mv "$tmp" "$FILE"
else
  python3 - "$FILE" "$NEXT_VERSION" <<'PY'
import json, sys
path, ver = sys.argv[1], sys.argv[2]
with open(path, 'r', encoding='utf-8') as f:
    data = json.load(f)
data['version'] = ver
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
    f.write('\n')
PY
fi

echo "Version bumped to $NEXT_VERSION in $FILE"
