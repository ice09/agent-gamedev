#!/usr/bin/env bash
# Startet die Begleit-Website zum Repository.
# Serviert den Projektordner per HTTP, damit alle verlinkten
# Dateien (Docs, Bilder, Screenshots) erreichbar sind:
#   http://localhost:8080/website/
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
port="${1:-8080}"

command -v python3 >/dev/null 2>&1 \
  || { echo "Fehler: python3 wird benötigt." >&2; exit 1; }

echo "Website: http://localhost:${port}/website/"
echo "Beenden mit Strg+C."
exec python3 -m http.server "$port" --directory "$project_dir"
