# Agent-Übergabe

## Deploy + GitHub-Push (18.09.)

- Website live (anonym, 24h): https://orchid-mirage-rpab.here.now/ – Bundle via
  neuem `website/build-deploy.sh` nach `build/website-deploy/` gebaut (alle
  ../-Links auf mitkopierte Dateien umgeschrieben, per curl verifiziert).
  Claim-URL zum dauerhaften Übernehmen beachten (nur einmal sichtbar).
- `README.md` mit Spiel-Screenshot (`docs/images/signal-infestation-*.png`)
  und Website-Link aufgewertet; `*Zone.Identifier` ins `.gitignore`.
- Commit `bc65abb` (248 Dateien: Iterationen, Website, Docs, Export-Skript,
  Game-Quellen; ohne `.env`, `dist/`, Tool-Junk). **Push offen:**
  `git@github.com: Permission denied (publickey)` – Public Key
  (`~/.ssh/id_rsa.pub`, Fingerprint siehe Handoff-Anhang) fehlt auf GitHub
  oder Repo `ice09/agent-gamedev` existiert nicht. Nichts davon ohne
  Nutzeraktion behebbar. Danach: `git push origin HEAD`.
- Unstaged/wissentlich draußen: Löschung `opencode.json`, `.playwright-mcp/`.

## Begleit-Website (neu)

- Neu `website/` (deutsch): Anleitung von WSL/Windows-Setup bis 1. Iteration,
  Dateien: `index.html`, `style.css`, `app.js`. Start aus dem Repo mit
  `./start-website.sh` (Port 8080, serviert den Projektordner, damit alle
  Links auf echte Dateien zeigen).
- Inhalte: WSL-, Godot-, OpenCode-Setup, Prüflauf, Spielidee, Art-Bibel mit
  eingebetteten Charakter-Referenzen, Parallax-Tabelle, Galerie mit 5
  Spiel-Screenshots aus `dist/level1/captures/`, Ausblick Iteration 2/3,
  Datei-Übersicht (25 Links), Fehlerhilfe, interaktive Checkliste (localStorage).
- Stil: Cyberpunk (Violett `#8A5CFF` aus der Spielpalette, Neon-Cyan), aber
  barrierearm: Skip-Link, semantisches HTML, Fokus-Rahmen, ausreichende
  Kontraste, `prefers-reduced-motion`, alles ohne JS nutzbar, keine externen
  Ressourcen. Eigene Screenshots: nach `dist/level1/captures/` legen und als
  `<figure>` ergänzen (Muster im HTML kommentiert).
- Geprüft: alle 25 Datei-Links + 9 Bilder per curl = HTTP 200; Seite im Browser
  gerendert (Header, Hero, Galerie per Screenshot kontrolliert); Favicon-404
  per Inline-SVG behoben. `README.md`-Doku-Übersicht um Website ergänzt.

## Template-Doku für GitHub-Release

- Root-`README.md` als Template-Einstieg neu aufgestellt (Flow 1→2→3,
  Schnellstart, eigenes Spiel, Export, Doku-Übersicht).
- Neu `docs/ASSETS.md`: KI-Asset-Guide (Chatmodell-Prompts, Palette- und
  Ebenen-Regeln, Code-Pipeline) mit verlinkten Beispielen aus dem Repo.
- Neu `docs/PUBLISH.md`: GitHub-Checkliste (Secrets, `C:devgamedev/`-Stray-Ordner
  mit `.env`-Kopie vor Push löschen, was committen, Lizenz-Hinweis, Release-exe
  als Anhang). Alle verlinkten Pfade geprüft, vorhanden.
- Rückverweise auf die Template-Docs in `1st_iter/`-, `2nd_iter/`- und
  `3rd_iter/`-README ergänzt. Nur Docs geändert, kein Code.
- Nächster Schritt: `C:devgamedev/`-Löschung freigeben (destruktiv), Lizenz
  wählen, dann nach `docs/PUBLISH.md` veröffentlichen.

## Dritte Iteration: `3rd_iter/` – Signal Infestation

- Aktuelle Distribution wieder unter `dist/level1/`: vollständige Kampfversion
  aus `3rd_iter/` übernommen, vorherige Traversal-Version auf Wunsch ersetzt.
  `dist/level1/project.godot` importieren, F5; WSL: `./dist/level1/tools/godot.sh`.
  Direkt dort Import, Smoke-Test und alle 142 Traversal-/Kampfchecks bestanden.
- Eigenständiges Godot-Projekt: `3rd_iter/project.godot` importieren, F5;
  WSL: `./3rd_iter/tools/godot.sh`. Gameplay-/Gegnerbrief und README liegen dort.
- Hauptfigur kann mit gehaltener Maustaste gezielt bzw. mit J horizontal feuern.
  Acht Gegner: Schienenbeißer, Augenquallen, Lückenchor und Nullkantor-Boss mit
  zweiter Phase. Telegraphierte Angriffe, Treffer, sechs Lebenspunkte, Reparaturen,
  Punkte, Checkpoint-Respawn, Pause, Sieg/Niederlage und vollständiger Neustart.
- Selbstständige Kopie mit eigenen Assets und sechs lokal erzeugten Soundeffekten;
  Physik-Interpolation und die geglättete Figurenanimation sind übernommen.
- Prüflauf erfolgreich: 83 Traversal-/Animationschecks + 59 Kampfchecks.
  Gerenderter Kampflauf: 67 Checks, acht Ansichten geprüft. Bewaffnete Figur:
  12 Pixel-Bewegungschecks bei 120 FPS / 60-Hz-Physik bestanden.
- Details, Kontrollschema und offene Prüfungen: `3rd_iter/AGENT_HANDOFF.md`.
- Neu: `tools/export-windows.sh [level] [ziel]` exportiert headless ein
  beliebiges `dist/<level>/`-Projekt als Windows-exe+pck und kopiert es nach
  `/mnt/c/gamedev_astra/dist/<level>/`. Erster Komplettlauf erfolgreich:
  `level1.exe` (109 MB) + `level1.pck` (591 KB) + `level1.console.exe`
  liegen in `C:\gamedev_astra\dist\level1\`.
- Stolperstein behoben: Templates aus Windows-Godot landen unter
  `%APPDATA%/Godot/export_templates/4.7.2.stable/` und sind für WSL unsichtbar.
  Dateien nach `~/.local/share/godot/export_templates/4.7.2.stable/` kopiert;
  das Skript übernimmt künftig Windows-seitige Templates automatisch.
  Korrekter Menüpfad: Editor -> Manage Export Templates (nicht Project-Menü).
- Nächster Schritt: `C:\gamedev_astra\dist\level1\level1.exe` auf Windows
  starten und komplett durchspielen (Schwierigkeit/Zielen/Ton bewerten).

## Art-Grundlage und frühere Traversal-Iteration (historischer Stand)

- `1st_interation.md` in `1st_iter/` umgesetzt: fünf unveränderte Spielerreferenzen,
  Character Bible, Palette, Art Direction, Environment-Prompt und Produktionsordner.
- `level1.md` als eigenständiges Godot-Projekt unter `dist/level1/` umgesetzt.
  Import: `dist/level1/project.godot`, F5; WSL: `./dist/level1/tools/godot.sh`.
- Zweite Iteration zuerst in `2nd_iter/GAMEPLAY.md` und `CHARACTER.md`
  beschrieben, danach spielbar umgesetzt: sichtbare animierte Hauptfigur,
  Laufen/Springen, Kamerafolge, Plattform-Checkpoints, Respawn und Ausgang.
  „No characters“ gilt für Umgebungstexturen, nicht für die spielbare Szene.
- Figur auf ca. 180 px vergrößert (1,6×, Kapsel 176 px), Gesicht/Brille,
  Mantel und Rüstung detaillierter. Rückwärts wirkenden Laufzyklus korrigiert:
  Standfuß läuft relativ zum Körper zurück, Vorschwingen erfolgt angehoben;
  Zyklustempo folgt der Bewegung. Größe bleibt bei Richtungswechsel/Respawn stabil.
- Armschwingen mit festen Segmentlängen, weichen Pose-Übergängen und weniger
  Kopfbewegung geglättet. Physik-Interpolation aktiviert; Kamera folgt im
  Physiktakt. Respawn/Richtungswechsel setzen Interpolation korrekt zurück.
- Level-Prüflauf erfolgreich: 83 Checks; gerenderter Lauf: 91 Checks;
  zusätzliche Pixel-Bewegungsprüfung bei 120 FPS / 60-Hz-Physik: 12 Checks.
  Ohne Interpolation reproduzierbare Aussetzframes, mit Interpolation keine.
  Alle sechs Lücken in beide Richtungen physikalisch durchquert; Figur in
  drei Bereichen sowie Lauf-/Sprungpose visuell geprüft.
- Details: `1st_iter/AGENT_HANDOFF.md` und `dist/level1/AGENT_HANDOFF.md`.
  `dist/` ist durch die bestehende `.gitignore` von normalem Git-Staging ausgenommen.
- Nächster Schritt: `dist/level1/` auf Windows durchspielen und Sprunggefühl
  sowie flüssige Arme/Bewegung ohne Zittern bewerten. A/D/Pfeile laufen,
  Leertaste/W/↑ springen, R Neustart.

## Neuer eigenständiger Stand: `dist_astra/` (2026-09-16)

- `2_AUFTRAG.md` erneut implementiert als eigenes Projekt unter `dist_astra/`:
  drei Dachrouten, neuer Kurier/Assets, Wächter, Menüs, Sammler, Audio/Persistenz.
- Start: `dist_astra/project.godot` in Godot 4.7.2 öffnen, F5; WSL alternativ
  `./dist_astra/tools/godot.sh`. Dieser Wrapper wählt immer das Astra-Projekt.
- Prüfung: `./dist_astra/tools/check-project.sh` erfolgreich, **146 Checks**
  einschließlich 57 physikalisch durchquerter Dachübergänge, Boss und Save/Load.
  Acht gerenderte Ansichten mit Forward+/Vulkan/lavapipe ohne Fehler geprüft.
- Neue Grafik-/Audioassets CC0, Google-Fonts-Schriften OFL; alle Quellen in
  `dist_astra/assets/CREDITS.md`. Assetbudget gemessen: ca. 1,36 MB.
- Ausführliche aktuelle Übergabe, Effektabschaltung und offene Prüfungen:
  `dist_astra/AGENT_HANDOFF.md`; Startanleitung: `dist_astra/README.md`.
- Nächster Schritt für Astra: Windows-Durchlauf aller drei Routen mit Ton
  und Bildratenkontrolle. Menschlicher Playtest/60-FPS-Nachweis stehen noch aus.

Die folgenden Abschnitte beschreiben den bisherigen Stammprojekt-/`dist_sol`-Stand.

## Aktueller Stand

- Zweiter Meilenstein "Neon Rush" ist vollständig implementiert: Cyberpunk-Jump-&-Run mit drei Leveln, Endgegner, Menü, Speicherung, Sound und Musik.
- Spielschleife: Hauptmenü → Levelauswahl → Level (`scenes/game/game.tscn`) → Ergebnisanzeige → nächster Sektor.
- Spieler: Coyote-Time, Jump-Buffer, variables Springen, Doppelsprung, Unverwundbarkeit nach Respawn, Kamera mit Vorausschau.
- Level als JSON in `data/levels/level_1..3.json`, aufgebaut von `scripts/level_builder.gd` (TileMapLayer für Optik, zusammengefasste Rechtecke für Kollision).
- Inhalte: Chips, Checkpoints, Stachel-/Todeszonen, bewegliche Plattformen, Walker und Drohnen, Endgegner mit Charge und Schussmuster (drei Stomps), Terminal erst nach Boss freigeschaltet.
- Optik: `forward_plus`, `WorldEnvironment` mit Glow, Parallax-Himmel in vier Ebenen, Regen- und Treffer-Partikel, `PointLight2D` an Spieler, Checkpoint und Terminal, Post-Effekt-Shader (Vignette, Scanlines, chromatische Aberration).
- Audio: Busse Master/Musik/Effekte, acht Soundeffekte (WAV), drei Musikschleifen (OGG), Lautstärke und Stumm in Einstellungen und Pause.
- Speicherung in `user://neon_rush.cfg`: Bestzeiten je Level, freigeschaltete Level, Audio-Einstellungen.
- Bonus aus Meilenstein 1 ("Sammler") ist über das Hauptmenü erreichbar; `scenes/main.tscn` und `scripts/main.gd` bleiben funktionsfähig.
- Eine eigenständig lauffähige Kopie liegt unter `dist_sol/`; `.gdignore` verhindert, dass das Stammprojekt deren GDScript-Klassen doppelt importiert.

## Wichtigste Dateien

- Autoload `scripts/game_state.gd` (Audio, Musik, Speicherung, Theme)
- Runner `scripts/game.gd`, Builder `scripts/level_builder.gd`, Spieler `scripts/player.gd`
- Gegner/Objekte: `walker.gd`, `drone.gd`, `boss.gd`, `boss_shot.gd`, `mover.gd`, `spikes.gd`, `chip.gd`, `checkpoint.gd`, `goal_terminal.gd`
- UI: `ui_kit.gd`, `hud.gd`, `pause_menu.gd`, `result_screen.gd`, `main_menu.gd`, `level_select.gd`, `settings.gd`
- Optik: `world_fx.gd`, `parallax_sky.gd`, `sprite_frames_util.gd`
- Assets: `assets/` inklusive `assets/CREDITS.md`; Erzeuger `tools/generate_assets.py` und `tools/generate_audio.py`
- Tests: `tests/test_neon_rush.tscn` (+`.gd`), `tests/test_game.gd`
- Prüfung: `tools/check-project.sh`

## Prüfstand

- `./tools/check-project.sh` erfolgreich: Import, 2 s Hauptszene, beide Logiktests (`test_game: OK`, `test_neon_rush: OK`).
- Derselbe Prüflauf war auch direkt in `dist_sol/` zweimal vollständig erfolgreich.
- `tests/test_neon_rush.gd` prüft: Menüaufbau, Springen, Doppelsprung, Laufen, Chip einsammeln, Tod durch Stacheln, Checkpoint-Respawn, Levelende am Terminal, bewegliche Plattform, Bosskontakt, drei Stomps und Terminal-Freischaltung, Pause/Fortsetzen, 2,5 s Smoke-Run, Speichern und Laden der Bestzeit.
- Sichtprüfung ohne Fenster möglich (lavapipe + xvfb), Beispiel:
  `xvfb-run -a -s "-screen 0 1280x720x24" env VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.json ./tools/godot.sh --rendering-driver vulkan <szene>`
  Damit wurden Hauptmenü und Level 1 gerendert und geprüft.

## Bekannte Probleme

- **Stray-Ordner `C:devgamedev/`** im Projektstamm: vollständige Kopie inklusive `.env`-Kopie und eigenem `.git`. Der Doppelpunkt ist im Windows-Dateisystem unzulässig und kann Checkout auf dem Zielsystem stören. In `.gitignore` aufgenommen, aber noch nicht gelöscht (destruktive Aktion, Freigabe nötig).
- Kein Audiogerät in dieser Umgebung (ALSA/Pulse fehlen), Wiedergabe läuft nur gegen den Dummy-Treiber; hörbar nur auf einem echten System.
- Kein interaktiver Playtest möglich, nur headless Tests und gerenderte Standbilder.
- Glow/Bloom setzt `forward_plus` voraus; auf sehr schwacher GPU ggf. `rendering_method` auf `mobile` stellen.

## Nächster Schritt

- Spiel auf Windows mit Godot 4.7.2 starten und die drei Level samt Endgegner durchspielen, um Handgefühl und Schwierigkeit zu bewerten.
