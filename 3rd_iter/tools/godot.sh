#!/usr/bin/env bash
set -euo pipefail
project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -n "${GODOT_BIN:-}" ]]; then
  exec "$GODOT_BIN" --path "$project_dir" "$@"
elif command -v godot >/dev/null 2>&1; then
  exec godot --path "$project_dir" "$@"
elif command -v godot4 >/dev/null 2>&1; then
  exec godot4 --path "$project_dir" "$@"
else
  printf '%s\n' 'Godot fehlt. GODOT_BIN auf Godot 4.7.2 setzen.' >&2
  exit 127
fi
