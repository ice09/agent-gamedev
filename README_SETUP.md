# Agent Game unter WSL starten

Dieses Paket ist für Entwicklung innerhalb von WSL vorbereitet. Lege das Projekt möglichst im Linux-Dateisystem ab, zum Beispiel unter `~/projects/agent-game`. Verzeichnisse unter `/mnt/c/...` sind für viele kleine Dateioperationen meist langsamer.

## 1. Paket entpacken

Wenn dein Zielordner bereits die `.env` enthält:

```bash
cd ~/projects/agent-game
unzip /pfad/zu/agent-game-wsl-starter.zip
chmod +x start-opencode.sh tools/*.sh
```

Die ZIP enthält bewusst keine `.env` und überschreibt deinen Schlüssel daher nicht.

## 2. Voraussetzungen prüfen

```bash
node --version
npm --version
godot --version || godot4 --version
```

OpenCode lässt sich aktuell per npm installieren:

```bash
npm install -g opencode-ai
```

Unter Windows empfiehlt OpenCode selbst WSL. Für Godot ist eine Linux-Binary in WSL am unkompliziertesten; unter Windows 11 kann die GUI über WSLg laufen. Wenn die Binary nicht `godot` oder `godot4` heißt, trage ihren absoluten Pfad in `.env` als `GODOT_BIN` ein.

## 3. `.env` prüfen

Die Datei muss im Projektstamm liegen und mindestens diese Zeile enthalten:

```dotenv
OPENROUTER_API_KEY=sk-or-v1-...
```

Der Schlüssel wird ausschließlich in den Prozess exportiert. OpenCode darf `.env` laut Projektberechtigungen weder lesen noch verändern.

## 4. Projekt testen

```bash
./tools/check-project.sh
```

Der Test öffnet Godot headless, importiert das Projekt und startet die Hauptszene kurz.

## 5. OpenCode starten

```bash
./start-opencode.sh
```

Der Starter liest nur `OPENROUTER_API_KEY` und optional `GODOT_BIN` aus `.env`, exportiert sie in den aktuellen OpenCode-Prozess und startet danach OpenCode. `/connect` ist deshalb nicht nötig.

Kopiere anschließend den Inhalt aus `ERSTER_AUFTRAG.md` in OpenCode.

## Modellwahl

- Hauptmodell: `openrouter/deepseek/deepseek-v4.1-flash`
- kleines internes Modell / günstiger Worker: `openrouter/deepseek/deepseek-v4-flash-0731`
- Review: DeepSeek V4.1 Flash, schreibgeschützt

Du kannst das aktive Modell in OpenCode mit `/models` kontrollieren oder ändern.

## Sicherheitsgrenzen

- `.env` ist durch `.gitignore` ausgeschlossen.
- Session-Sharing ist deaktiviert.
- Externe Verzeichnisse sind gesperrt.
- `git push`, `git reset --hard`, `git clean` und `rm -rf` sind gesperrt.
- Commits und unbekannte Shell-Befehle erfordern Rückfrage.

