#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
godot_runner="$project_dir/tools/godot.sh"

cd "$project_dir"

run_step() {
  local name="$1"
  shift
  local output
  if ! output="$("$@" 2>&1)"; then
    echo "$output"
    echo "FEHLER: $name ist fehlgeschlagen." >&2
    exit 1
  fi
  if echo "$output" | grep -E "^(SCRIPT ERROR|ERROR:)" | grep -vqE "resources still in use|ObjectDB instances"; then
    echo "$output"
    echo "FEHLER: $name meldet Fehler." >&2
    exit 1
  fi
  echo "$name ok"
}

run_step "[1/3] Projekt importieren" "$godot_runner" --headless --editor --quit
run_step "[2/3] Hauptszene ausführen" "$godot_runner" --headless --quit-after 2
run_step "[3/3] Spiellogik-Test Sammler" "$godot_runner" --headless --script tests/test_game.gd
run_step "[3/3] Spiellogik-Test Neon Rush" "$godot_runner" --headless tests/test_neon_rush.tscn

echo "Godot-Prüfung erfolgreich."
