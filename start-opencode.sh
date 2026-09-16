#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
env_file="$project_dir/.env"

if [[ ! -f "$env_file" ]]; then
  echo "Fehler: $env_file fehlt. Lege dort OPENROUTER_API_KEY ab." >&2
  exit 1
fi

read_env_value() {
  local wanted_key="$1"
  local line value=""

  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    case "$line" in
      "$wanted_key="*) value="${line#*=}" ;;
      "export $wanted_key="*) value="${line#*=}" ;;
    esac
  done < "$env_file"

  if [[ ${#value} -ge 2 ]]; then
    if [[ "${value:0:1}" == '"' && "${value: -1}" == '"' ]]; then
      value="${value:1:${#value}-2}"
    elif [[ "${value:0:1}" == "'" && "${value: -1}" == "'" ]]; then
      value="${value:1:${#value}-2}"
    fi
  fi

  printf '%s' "$value"
}

export OPENROUTER_API_KEY="$(read_env_value OPENROUTER_API_KEY)"

if [[ -z "$OPENROUTER_API_KEY" ]]; then
  echo "Fehler: OPENROUTER_API_KEY ist in .env nicht gesetzt." >&2
  exit 1
fi

godot_bin_value="$(read_env_value GODOT_BIN)"
if [[ -n "$godot_bin_value" ]]; then
  export GODOT_BIN="$godot_bin_value"
fi

if ! command -v opencode >/dev/null 2>&1; then
  echo "Fehler: opencode wurde nicht gefunden. Installiere es mit: npm install -g opencode-ai" >&2
  exit 1
fi

cd "$project_dir"
exec opencode

