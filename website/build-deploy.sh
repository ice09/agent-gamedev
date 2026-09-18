#!/usr/bin/env bash
# Baut ein eigenständiges Deploy-Bundle der Website nach build/website-deploy/.
# Alle ../-Links werden auf mitkopierte Dateien umgeschrieben, sodass das
# Bundle ohne das restliche Repository funktioniert (z. B. für here.now).
# Usage: ./website/build-deploy.sh
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
src_dir="$repo_root/website"
out_dir="$repo_root/build/website-deploy"

rm -rf "$out_dir"
mkdir -p "$out_dir"

# 1. HTML übernehmen, ../-Links in href/src auf Bundle-Pfade umschreiben.
sed -E 's/((href|src)=")\.\.\//\1/g' "$src_dir/index.html" \
  | sed 's|starte sie per <code>./start-website.sh</code> aus dem Projektordner|Stand des Repositorys zum Deploy-Zeitpunkt – lokal starten mit <code>./start-website.sh</code>|' \
  > "$out_dir/index.html"
cp "$src_dir/style.css" "$src_dir/app.js" "$out_dir/"

# 2. Alle per ../ referenzierten Dateien/Ordner einsammeln (Pfade erhalten).
grep -oE '(href|src)="\.\./[^"]*"' "$src_dir/index.html" \
  | sed -E 's/^(href|src)="\.\.\///; s/"$//' \
  | sort -u \
  | while IFS= read -r ref; do
      # Anker/ leere Refs und externe URLs überspringen
      case "$ref" in ""|"http"*|"#*") continue ;; esac
      # Verzeichnis-Link (endet auf /): ganzen Ordner kopieren
      if [[ "$ref" == */ ]]; then
        dir="${ref%/}"
        if [[ -d "$repo_root/$dir" ]]; then
          mkdir -p "$out_dir/$dir"
          cp -r "$repo_root/$dir/." "$out_dir/$dir/"
          echo "dir:  $dir"
        else
          echo "WARN: Verzeichnis fehlt: $dir" >&2
        fi
      else
        if [[ -f "$repo_root/$ref" ]]; then
          mkdir -p "$out_dir/$(dirname "$ref")"
          cp "$repo_root/$ref" "$out_dir/$ref"
          echo "file: $ref"
        else
          echo "WARN: Datei fehlt: $ref" >&2
        fi
      fi
    done

echo "Bundle fertig: $out_dir ($(du -sh "$out_dir" | cut -f1))"
