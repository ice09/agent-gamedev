# Agent Game

Ein kleines Experiment: Ein vollständiges 2D-Spiel in Godot, das ein KI-Agent
(OpenCode über OpenRouter) im Repository selbst umsetzt. Der Mensch formuliert
nur das Ziel und bewertet das spielbare Ergebnis.

## Idee

- `GAME_SPEC.md` beschreibt verbindlich, was das Spiel können soll.
- `AGENTS.md` beschreibt, wie der Agent arbeiten soll.
- Der Agent legt Szenen, Skripte und Daten selbst an, prüft sie und pflegt
  `AGENT_HANDOFF.md`.
- Der erste Meilenstein ist bewusst klein: WASD-Bewegung, Sammelobjekte,
  Punktestand, Gefahren, Game Over, Neustart – nur Godot-Primitiven, keine
  externen Assets.

## Voraussetzungen

- WSL (Linux-Dateisystem, nicht `/mnt/c/...`)
- Node.js und npm
- Godot 4.7.2 als `godot` oder `godot4` im PATH (sonst `GODOT_BIN` in `.env`)
- OpenCode: `npm install -g opencode-ai`

## Erste Schritte

1. **OpenRouter-Key holen**: auf <https://openrouter.ai/keys> einen Key
   anlegen (kostenpflichtiges Guthaben nötig).
2. **`.env` anlegen**: `cp .env.example .env` und den Key eintragen:

   ```dotenv
   OPENROUTER_API_KEY=sk-or-v1-...
   ```

   Die `.env` ist per `.gitignore` ausgeschlossen und für OpenCode gesperrt.
   Details und Alternativen (`GODOT_BIN`) in `README_SETUP.md`.
3. **Projekt prüfen**: `./tools/check-project.sh` – importiert das Projekt
   headless und startet die Hauptszene kurz.
4. **OpenCode starten**: `./start-opencode.sh` – exportiert den Key in den
   Prozess und startet OpenCode; `/connect` ist nicht nötig.
5. **Auftrag einfügen**: den Text aus `ERSTER_AUFTRAG.md` in OpenCode
   kopieren. Der Agent implementiert dann den ersten Meilenstein.

## Modell

- Hauptmodell: `openrouter/deepseek/deepseek-v4.1-flash`
- Günstiger Worker: `openrouter/deepseek/deepseek-v4-flash-0731`

Wechseln mit `/models` in OpenCode.

## Sicherheit

`opencode.json` erlaubt nur das Nötigste und lässt OpenCode um Erlaubnis
fragen, bevor er Unbekanntes ausführt oder committet. `.env` ist gesperrt,
ebenso `git push`, `git reset --hard`, `git clean` und `rm -rf`.

Für einen unbeaufsichtigten Durchlauf („Yolo-Modus") die `permission`-Regeln
in `opencode.json` lockern – bewusst und auf eigenes Risiko.

## Weiterlesen

- `README_SETUP.md` – ausführliches WSL-Setup
- `GAME_SPEC.md` – was gebaut wird
- `AGENTS.md` – Arbeitsweise des Agenten
- `ERSTER_AUFTRAG.md` – Startauftrag zum Einfügen
