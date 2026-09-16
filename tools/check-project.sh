#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
godot_runner="$project_dir/tools/godot.sh"

cd "$project_dir"

echo "[1/2] Projekt importieren und Editor-Daten prüfen"
"$godot_runner" --headless --editor --quit

echo "[2/2] Hauptszene kurz ausführen"
"$godot_runner" --headless --quit-after 2

echo "Godot-Prüfung erfolgreich."

