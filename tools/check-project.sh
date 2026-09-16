#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
godot_runner="$project_dir/tools/godot.sh"

echo "[1/2] Projekt importieren und Editor-Daten prüfen"
"$godot_runner" --headless --path "$project_dir" --editor --quit

echo "[2/2] Hauptszene kurz ausführen"
"$godot_runner" --headless --path "$project_dir" --quit-after 2

echo "Godot-Prüfung erfolgreich."

