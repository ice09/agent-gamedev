---
name: godot-pruefen
description: Prüft das Godot-Projekt nach Code- oder Szenenänderungen mit dem lokalen WSL-Wrapper und leitet eine kurze Fehlerbehebungsschleife an
compatibility: opencode
metadata:
  sprache: de
  engine: godot-4.7.2
---

# Godot-Projekt prüfen

Verwende diesen Skill nach Änderungen an GDScript, Szenen, Ressourcen oder `project.godot`.

## Ablauf

1. Führe `./tools/check-project.sh` aus.
2. Lies die vollständigen Fehlermeldungen, ohne Secrets oder `.env` zu öffnen.
3. Ordne jeden Fehler der kleinsten wahrscheinlichen Ursache zu.
4. Korrigiere nur projektinterne Fehler, die im Rahmen der aktuellen Aufgabe liegen.
5. Wiederhole den Prüflauf, bis er erfolgreich ist oder ein externer Blocker eindeutig feststeht.
6. Melde den ausgeführten Befehl, das Ergebnis und verbleibende Blocker.

Überspringe den Lauf nicht nur deshalb, weil eine Änderung klein erscheint.

