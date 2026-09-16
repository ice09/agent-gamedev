# Agent-Übergabe

## Aktueller Stand

- Das minimale Godot-4.7.2-Projekt ist angelegt.
- `scenes/main.tscn` ist als Hauptszene konfiguriert.
- Die Szene zeigt nur einen Start-Hinweis; der spielbare Meilenstein ist noch nicht implementiert.
- OpenCode nutzt OpenRouter mit DeepSeek V4.1 Flash als Hauptmodell.
- WSL-Starter und Godot-Prüfskripte sind vorhanden.

## Nächste Aufgabe

Den ersten spielbaren Meilenstein aus `GAME_SPEC.md` vollständig implementieren und mit `./tools/check-project.sh` prüfen.

## Prüfstand

- `./tools/check-project.sh` ist ausführbar und läuft mit der nativen Linux-Binary erfolgreich durch (Import + 2 s Hauptszene).

## Bekannte Probleme

- Godot 4.7.2 ist als Linux-Binary unter `~/.local/bin/godot` installiert und liegt im PATH; `GODOT_BIN` ist dafür nicht nötig.
- Falls `.env` noch ein `GODOT_BIN` auf die Windows-Binary zeigt, dieses entfernen oder leer lassen, damit die native Binary genutzt wird.
- `check-project.sh` setzt das Arbeitsverzeichnis statt `--path` zu übergeben. Das hält auch den Windows-Fallback (WSL-Interop) lauffähig.

