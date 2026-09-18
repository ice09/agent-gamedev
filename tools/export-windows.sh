#!/usr/bin/env bash
# Exports any standalone project under dist/<level>/ to a Windows .exe
# headlessly and copies the artifacts to the Windows side.
#
# Usage: ./tools/export-windows.sh [level] [dest_dir]
#   level     folder under dist/ (default: level1)
#   dest_dir  Windows target dir (default: /mnt/c/gamedev_astra/dist/<level>)
#
# Produces: <level>.exe + <level>.pck (Godot 4 Windows export).
# One-time requirement: export templates 4.7.x installed
# (Godot editor: Editor -> Manage Export Templates... -> check
#  "Windows 64-bit" -> Install Selected Templates).
set -euo pipefail

LEVEL="${1:-level1}"
PRESET="Windows Desktop"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_ROOT/dist/$LEVEL"
DEST="${2:-/mnt/c/gamedev_astra/dist/$LEVEL}"
STAGE="$REPO_ROOT/build/windows/$LEVEL"
EXE="$STAGE/$LEVEL.exe"

die() { printf 'FEHLER: %s\n' "$*" >&2; exit 1; }

[[ -f "$SRC/project.godot" ]] || die "Kein Godot-Projekt: $SRC/project.godot (bekannt: $(ls "$REPO_ROOT/dist" 2>/dev/null | tr '\n' ' '))"

if [[ -n "${GODOT_BIN:-}" ]]; then
  GODOT="$GODOT_BIN"
elif command -v godot >/dev/null 2>&1; then
  GODOT="$(command -v godot)"
elif command -v godot4 >/dev/null 2>&1; then
  GODOT="$(command -v godot4)"
else
  die "Godot nicht gefunden. GODOT_BIN auf Godot 4.7.2 setzen."
fi
echo "Godot: $("$GODOT" --version)"

# Preset anlegen (nur wenn Datei fehlt; bestehende Presets nie überschreiben).
if [[ ! -f "$SRC/export_presets.cfg" ]]; then
  cat > "$SRC/export_presets.cfg" <<EOF
[preset.0]

name="$PRESET"
platform="Windows Desktop"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="../../build/windows/$LEVEL/$LEVEL.exe"
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false

[preset.0.options]

custom_template/debug=""
custom_template/release=""
debug/export_console_wrapper=2
binary_format/embed_pck=false
texture_format/bptc=true
texture_format/s3tc=true
texture_format/etc=false
texture_format/etc2=false
binary_format/architecture="x86_64"
codesign/enable=false
application/modify_resources=true
application/icon=""
application/icon_interpolation=4
application/file_version=""
application/product_version=""
application/company_name=""
application/product_name=""
application/file_description=""
application/copyright=""
application/trademarks=""
texture_format/s3tc_bptc=true
texture_format/etc2_astc=false
shader_baker/enabled=false
application/export_angle=0
application/export_d3d12=0
dotnet/include_scripts_content=false
dotnet/include_debug_symbols=true
dotnet/embed_build_outputs=false
EOF
  echo "Preset angelegt: $SRC/export_presets.cfg"
fi
grep -q 'platform="Windows Desktop"' "$SRC/export_presets.cfg" \
  || die "Kein \"$PRESET\"-Preset in $SRC/export_presets.cfg. Im Editor unter Project -> Export... hinzufügen."

# Export-Templates vorhanden? (Netzwerk-Download bewusst nicht automatisch.)
# Hinweis: Templates aus einem Windows-nativen Godot landen unter
# %APPDATA%/Godot/export_templates und sind für WSL-Godot unsichtbar.
if ! find ~/.local/share/godot/export_templates -iname '*windows*64*' 2>/dev/null | grep -q .; then
  for win_dir in /mnt/c/Users/*/AppData/Roaming/Godot/export_templates/*/; do
    if ls "$win_dir"windows_*64*.exe >/dev/null 2>&1; then
      ver="$(basename "$win_dir")"
      mkdir -p ~/.local/share/godot/export_templates/"$ver"
      cp --update=none "$win_dir"windows_*64*.exe ~/.local/share/godot/export_templates/"$ver"/
      echo "Templates von Windows-Seite übernommen: $win_dir"
      break
    fi
  done
fi
if ! find ~/.local/share/godot/export_templates -iname '*windows*64*' 2>/dev/null | grep -q .; then
  die "Windows-Export-Templates fehlen. Im Editor: Editor -> Manage Export Templates... -> Haken bei \"Windows 64-bit\" -> Install Selected Templates (Details in AGENT_HANDOFF.md)."
fi

echo "Importiere $SRC ..."
"$GODOT" --headless --path "$SRC" --editor --quit

echo "Exportiere $LEVEL -> $EXE ..."
mkdir -p "$STAGE"
"$GODOT" --headless --path "$SRC" --export-release "$PRESET" "$EXE"

[[ -f "$EXE" ]] || die "Export hat keine exe erzeugt."
ls -la "$STAGE"

mkdir -p "$DEST"
cp -f "$STAGE"/"$LEVEL".exe "$STAGE"/"$LEVEL".pck "$STAGE"/"$LEVEL".console.exe "$DEST"/ 2>/dev/null \
  || cp -f "$STAGE"/* "$DEST"/
echo "Kopiert nach $DEST:"
ls -la "$DEST"
echo "Fertig. Auf Windows $DEST/$LEVEL.exe starten (exe + pck gehören zusammen)."
