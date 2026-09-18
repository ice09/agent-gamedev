# Als GitHub-Template veröffentlichen – Checkliste

Ziel: Freunde klonen das Repo und können denselben Flow (Brief → Agent →
spielen → exportieren) nachvollziehen. Aktuell sind nur 23 Dateien getrackt;
`1st_iter/`, `2nd_iter/`, `3rd_iter/` und `dist/` sind noch nicht committed.

## 1. Secrets entfernen

- `.env` enthält den OpenRouter-Key und darf **nie** ins Repo. `.gitignore`
  schließt `.env` bereits aus – vor dem Push prüfen: `git status` darf keine
  `.env` zeigen. Nur `.env.example` (Platzhalter) committen.
- **Stray-Ordner `C:devgamedev/` im Projektstamm löschen** (enthält eine
  `.env`-Kopie plus eigenes `.git`; der Doppelpunkt bricht Windows-Checkouts).
  Destruktiv – bewusst freigeben, nicht nebenbei löschen. Danach gehört der
  Name zusätzlich in `.gitignore`.
- Keine API-Keys, Tokens oder Screenshots mit Keys in `captures/` oder Docs.

## 2. Entscheiden, was committed wird

Empfehlung für ein Template-Repo:

```bash
git add README.md README_SETUP.md GAME_SPEC.md AGENTS.md AGENT_HANDOFF.md \
  ERSTER_AUFTRAG.md .env.example .gitignore \
  docs/ 1st_iter/ 2nd_iter/ 3rd_iter/ \
  tools/export-windows.sh project.godot scenes/ scripts/ data/ \
  assets/CREDITS.md assets/fonts/ tools/generate_*.py
```

Bewusst **nicht** committen (stehen schon in `.gitignore`):

- `dist/` – enthält die Beispielspiele; Freunden zum Ausprobieren als
  Release-exe geben statt ins Repo. Wer `dist/level1/` als Quelltext teilen
  will: gezielt `git add -f dist/level1` für Quellen (Szenen, Skripte, SVGs,
  Docs), aber `.godot/`, `*.pck`, `*.exe`, `build/` und große `captures/`
  draußen lassen.
- `build/`, `exports/`, `.godot/`, `*.log`, `.opencode/cache|storage/`.
- Generierte Binär-Assets nur, wenn klein und nötig; große PNGs lieber als
  Release-Anhang statt im Git.

Vor dem Push kontrollieren: `git status --short` und `git diff --cached
--stat` lesen, keine Secrets, keine Binär-Blobs aus Versehen dabei.

## 3. Lizenz wählen

Aktuell liegt **keine LICENSE** bei – ohne sie ist das Repo rechtlich
„alle Rechte vorbehalten“, auch als öffentliches Repo. Für ein Starter-Template
empfiehlt sich MIT (`LICENSE` mit MIT-Text anlegen). Hinweis: Mitgebrachte
OFL-Fonts (`assets/fonts/`) bleiben OFL-lizenziert, das in `assets/CREDITS.md`
dokumentieren.

## 4. GitHub einrichten

- Neues Repo anlegen, als **Template repository** markieren (Settings →
  Template repository), damit Freunde per „Use this template“ starten.
- `README.md` ist die Startseite – sie verweist auf den gesamten Flow.
- Ersten Stand als Release taggen (z. B. `v0.1-template`), die Windows-exe
  (`level1.exe` + `level1.pck` aus `C:\gamedev_astra\dist\level1\`) als
  Release-Anhang hochladen statt ins Git.
- Repo-Beschreibung + Topics setzen (z. B. `godot`, `gdscript`, `game-template`).

## 5. Nach dem Klonen (für Freunde)

```bash
cp .env.example .env     # Key eintragen
./tools/check-project.sh # Prüfung
./start-opencode.sh      # Agent starten
```

Weiter geht es mit `ERSTER_AUFTRAG.md` bzw. den Briefs in `1st_iter/`,
`2nd_iter/`, `3rd_iter/`.
