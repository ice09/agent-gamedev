#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${GODOT_BIN:-}" ]]; then
  godot_command="$GODOT_BIN"
elif command -v godot >/dev/null 2>&1; then
  godot_command="$(command -v godot)"
elif command -v godot4 >/dev/null 2>&1; then
  godot_command="$(command -v godot4)"
else
  echo "Fehler: Godot wurde nicht gefunden. Setze GODOT_BIN oder installiere godot/godot4 in WSL." >&2
  exit 127
fi

exec "$godot_command" "$@"

