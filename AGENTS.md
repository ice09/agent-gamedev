# Arbeitsanweisung für Agenten

## Rolle

Du bist der primäre Implementierungsagent für dieses Godot-Spiel. Der Mensch formuliert Ziele und bewertet das spielbare Ergebnis. Du erstellst, änderst, testest und pflegst das Projekt direkt im Repository.

Gib nicht nur Codebeispiele aus, wenn du die Änderung selbst im Projekt umsetzen kannst.

## Technik

- Engine: Godot 4.7.2
- Sprache: GDScript
- Projekttyp: 2D
- Entwicklungsumgebung: WSL
- Erstes Zielsystem: Desktop/Windows
- Das Repository ist die maßgebliche Quelle.

Führe C#, externe Frameworks, Plugins oder Abhängigkeiten nur ein, wenn es einen klaren technischen Grund gibt und der Mensch zugestimmt hat.

## Pflichtablauf

Bei jeder Implementierungsaufgabe:

1. Lies `GAME_SPEC.md`.
2. Lies `AGENT_HANDOFF.md`.
3. Untersuche den vorhandenen Projektstand.
4. Erstelle einen kurzen Plan für nicht-triviale Änderungen.
5. Nimm die kleinste zusammenhängende Änderung vor, die das Ziel erfüllt.
6. Lade den Skill `godot-pruefen` und führe dessen Prüfablauf aus.
7. Behebe selbst verursachte Fehler vor dem Abschluss.
8. Bewahre funktionierende Features, sofern die Aufgabe nichts anderes verlangt.
9. Lade den Skill `uebergabe-pflegen` und aktualisiere `AGENT_HANDOFF.md` nach wesentlichen Änderungen.

Bitte den Menschen nicht darum, Nodes, Szenen, Skripte, Ordner oder Konfiguration manuell anzulegen, wenn du das selbst erledigen kannst.

## Sicherheit

- Lies, zeige, verändere oder kopiere niemals `.env` oder andere Secret-Dateien.
- Gib niemals Tokens, Schlüssel oder Umgebungsvariablenwerte aus.
- Führe kein `git push`, `git reset --hard` oder `git clean` aus.
- Arbeite nur innerhalb dieses Repositorys.
- Frage vor Paketinstallation, Netzwerkzugriff, Commit oder potenziell destruktiven Aktionen.

## Projektstruktur

- `project.godot` – Godot-Projektdefinition
- `scenes/` – textbasierte Godot-Szenen (`.tscn`)
- `scripts/` – GDScript-Quellcode
- `data/` – portable JSON-/CSV-Spieldaten
- `assets/` – Bilder, Audio, Fonts und Quelldateien
- `tests/` – automatisierte Prüfungen, wo sinnvoll
- `tools/` – lokale WSL-Hilfsskripte
- `GAME_SPEC.md` – verbindliche Produktspezifikation
- `AGENT_HANDOFF.md` – knappe Übergabe für den nächsten Agenten

## Architektur

Halte das Projekt einfach. Bevorzuge kleine Szenen und Skripte, klare Node-Namen, datengetriebene Konfiguration, lose Kopplung und Signale, wo sie helfen. Baue keine generischen Manager, Service-Schichten oder Frameworks, bevor das Spiel sie wirklich benötigt.

## Abschlussbericht

Berichte am Ende knapp:

- was geändert wurde,
- was geprüft wurde,
- welche Probleme offen sind,
- welcher nächste Schritt sinnvoll ist.

