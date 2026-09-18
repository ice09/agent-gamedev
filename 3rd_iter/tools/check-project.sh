#!/usr/bin/env bash
set -euo pipefail
project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
runner="$project_dir/tools/godot.sh"
run() {
  local title="$1" output
  shift
  if ! output="$(timeout 180 "$runner" --audio-driver Dummy "$@" 2>&1)"; then
    printf '%s\n' "$output" "FEHLER: $title" >&2
    exit 1
  fi
  printf '%s\n' "$output"
  if [[ "$output" == *"SCRIPT ERROR"* || "$output" == *"ERROR:"* ]]; then
    printf 'FEHLER: %s\n' "$title" >&2
    exit 1
  fi
  printf 'OK: %s\n' "$title"
}
run 'Import' --headless --editor --quit
run 'Main scene smoke test' --headless --quit-after 120
run 'Environment, collision, camera and controls' --headless --fixed-fps 60 res://tests/test_level1.tscn
run 'Combat, enemies, boss and full restart' --headless --fixed-fps 60 res://tests/test_combat.tscn
printf '%s\n' 'Signal Infestation: Godot-Prüfung erfolgreich.'
