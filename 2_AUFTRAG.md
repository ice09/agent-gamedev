# Zweiter Auftrag für OpenCode

Füge den folgenden Auftrag in OpenCode ein.

Dieser Auftrag ist bewusst größer als der erste. Der Mensch hat Folgendes
freigegeben und trägt die höheren Kosten bewusst:

- echte, externe Assets (Grafik, Sound, Musik) sind erlaubt,
- Netzwerkzugriff ist für diesen Auftrag freigegeben (Download von CC0-Assets
  und Paketinstallation, wenn technisch nötig),
- der Renderer darf auf `forward_plus` umgestellt werden,
- Persistenz lokaler Bestwerte und Einstellungen ist erlaubt.

Die Einschränkungen aus `GAME_SPEC.md` („Nicht Teil des ersten Meilensteins")
gelten für diesen Meilenstein nur noch, soweit sie hier nicht ausdrücklich
aufgehoben werden.

```text
Lies AGENTS.md, GAME_SPEC.md und AGENT_HANDOFF.md vollständig.

Baue auf dem ersten Meilenstein auf und implementiere den zweiten Meilenstein:
"Neon Rush" – ein vollständiges Cyberpunk-Jump-&-Run in Godot 4.7.2 mit GDScript,
echten Assets und einem glaubwürdigen Neon-Look.

Der Mensch hat ausdrücklich freigegeben: externe Assets erlauben, Netzwerkzugriff
für diesen Auftrag nutzen, Renderer auf forward_plus umstellen, lokale Bestwerte
und Einstellungen speichern. Die Netzwerk-Rückfrage aus AGENTS.md gilt für diesen
Auftrag als erteilt; kostenpflichtige Dienste sind weiterhin ausgeschlossen.
Lädt Assets herunter oder installiert Pakete nur, wenn es der Aufgabe dient, und
dokumentiere jede Quelle.

Arbeite eigenständig: Lege Szenen, Skripte, Assets und Einstellungen selbst an.
Halte die Architektur klein und verständlich. Nutze den cheap-worker für klar
abgegrenzte mechanische Teilaufgaben und den reviewer für eine abschließende
schreibgeschützte Kontrolle.

## 1. Spielziel und Kernschleife

- Drei handgebaute Level mit steigender Schwierigkeit (je etwa 60 bis 120 s).
- Start im Hauptmenü: Spielen, Level auswählen, Einstellungen, Beenden;
  dazu der Bonus-Modus "Sammler" (die Szene des ersten Meilensteins).
- Kernschleife: vom Startpunkt zum Ziel-Terminal, Datenchips sammeln,
  Gegnern und Gefahren ausweichen, Checkpoints aktivieren.
- Tod setzt am letzten Checkpoint zurück, erhöht den Todeszähler und ist
  sichtbar rückmeldbar. Kein Respawn-Death-Loop.
- Levelende am Terminal mit Ergebnisansicht (Chips, Tode, Zeit, Bestzeit).
- Bestzeit je Level bleibt lokal erhalten (user://).
- Das dritte Level endet mit einem kleinen Endgegner (drei Treffer,
  zwei Angriffsmuster) vor dem Terminal.
- Pause jederzeit per Taste, mit Fortsetzen, Neustart, Menü und Lautstärke.

## 2. Spieler und Steuerung

- `CharacterBody2D` mit Schwerkraft, Boden- und Wandkollision.
- Laufen mit WASD und Pfeiltasten, Springen mit Leertaste oder W/Up.
- Gute Sprungphysik: Coyote-Time, Jump-Buffer, variable Sprunghöhe über die
  Tastendruckdauer, ein Doppelsprung, alternativ ein Wandabsprung.
- Eigene `InputMap`-Aktionen in `project.godot` (links, rechts, springen,
  pause, neustart) mit WASD, Pfeiltasten und Leertaste belegt. Keine
  Tastaturabfrage über fest verdrahtete Tastencodes.
- Kurze Unverwundbarkeit nach Respawn und nach Treffer, mit klar sichtbarem
  Blinken.
- Alle Werte (Geschwindigkeit, Sprungkraft, Schwerkraft, Coyote-Zeit,
  Buffer-Zeit) liegen zentral und klar benannt als `@export` oder Konstanten.

## 3. Level und Inhalte

- Levelaufbau mit `TileMapLayer` und einem `TileSet`, das aus den Assets
  aufgebaut wird (Terrarian, Hintergrund, Dekoration, Gefahren).
- Pro Level mindestens: statische und bewegliche Plattformen, tödliche
  Stacheln bzw. Todeszonen, tödliche Abgründe, Checkpoints, Ziel-Terminal.
- Mindestens zwei Gegnertypen mit einfachem Zustandsverhalten, zum Beispiel
  ein patrouillierender Bodenläufer und eine fliegende Drohne.
- Datenchips als Sammelobjekte, einzeln und als kleine Reihen.
- Ein Sprung, der den Doppelsprung verlangt, und eine Timing-Passage pro Level.
- Kamera folgt mit Vorausschau, sanftem Nachziehen und harten Level-Limits
  (kein Blick über den Levelrand).

## 4. Grafik: Cyberpunk

- Renderer in `project.godot` auf `forward_plus` umstellen. Begründung:
  Bloom/Glow wird im bisherigen `gl_compatibility` nicht unterstützt.
  Auf schwächeren Rechnern muss alternativ `mobile` möglich bleiben.
- `WorldEnvironment` mit Glow/Bloom, Dunst und Color-Grading (Neon-Violett
  und Cyan auf dunklem Grund).
- Parallax-Hintergrund in mindestens drei Ebenen (Skyline, Neon-Schilder,
  Regen) mit echten oder prozedural erzeugten Texturen.
- Animierte Spielfigur über `AnimatedSprite2D` mit mindestens Laufen, Springen,
  Fallen und Treffer. Keine Standbild-Figur.
- Neon-Optik über emissive Materialien in Kombination mit Glow und
  `PointLight2D` für lokale Leuchteffekte.
- `GPUParticles2D` für Regen, Funken, Staub, Sprungwolken und Trefferfeedback.
- Subtiler Post-Effekt-Shader: Vignette, Scanlines, minimale chromatische
  Aberration. Dosiert einsetzen, Lesbarkeit hat Vorrang.
- Klare Lesbarkeit trotz Effekte: Spieler und Gefahren bleiben eindeutig
  erkennbar, Effekte dürfen Gameplay nicht verdecken.
- Ziel: stabile 60 FPS pro Level bei begrenzten Partikelmengen.

## 5. Audio

- Audio-Bus-Layout in Godot mit mindestens Master, Musik und Effekten.
- Effekte: Sprung, Landung, Chip einsammeln, Checkpoint, Treffer, Tod,
  Levelende, Knopfklick.
- Musik: je Level ein loopender Track, Menü-Musik, Endgegner-Track.
- Einstellungen für Master-, Musik- und Effektlautstärke, sofort wirksam und
  lokal gespeichert; dazu ein Stummschalter.
- Formate: Musik als OGG, Effekte als WAV. Keine unkomprimierten Musikdateien.

## 6. Assets: Herkunft und Pflichten

- Erlaubt sind echte Asset-Dateien, die im Projekt liegen: Sprites, Tilesets,
  Animationen, Sounds, Musik, Fonts.
- Zwei gleichwertige Wege:
  1. Selbst erzeugen und als echte Dateien in `assets/` ablegen, zum Beispiel
     prozedural generierte PNGs (Skript mit Python/PIL, ImageMagick oder einem
     Godot-Tool-Skript) und synthetisierte WAV-/OGG-Audio via Skript.
  2. CC0-Pakete herunterladen, bevorzugt von Anbietern wie Kenney oder
     OpenGameArt. Netzwerkzugriff ist für diesen Auftrag freigegeben.
- Bevorzuge CC0-Pakete, wenn sie schneller zu einem stimmigen Look führen,
  etwa für Tilesets, Tilemaps, Charakter-Animationen und Soundbibliotheken.
  Erzeuge selbst nur, was es als freies Paket nicht sinnvoll gibt.
- Lizenzpflicht: Jede verwendete Quelle in `assets/CREDITS.md` mit Name,
  Herkunft, Lizenz und Datum eintragen. Auch selbst erzeugte Assets vermerken.
  Kein Asset ohne dokumentierte Lizenz verwenden.
- Pixelart wird mit Nearest-Filter importiert, Musik und Effekte mit sauberen
  Loop-Punkten.
- Budget: keine Textur über 2048 px, Gesamtgröße der Assets unter etwa 30 MB,
  Partikel- und Effektanzahl begrenzt.
- Keine kostenpflichtigen oder nicht klar lizenzierten Inhalte.
- Urheber- und Herkunftsangaben nicht entfernen, wenn eine Lizenz das verlangt.
- Keine Cheat-Quellen oder Dubletten mit unklarer Herkunft; lade von der
  offiziellen Projektseite des Anbieters.

## 7. UI und Persistenz

- Hauptmenü, Levelauswahl, Einstellungen, Pause und Ergebnisansicht als
  `Control`-UI im Neon-Stil, mit Tastatur und Maus bedienbar.
- HUD: Chips, Tode, Zeit, Levelname, Checkpoint-Feedback.
- Texte deutsch, Fonts als echte Asset-Datei eingebunden.
- Lokale Speicherung in `user://`: Bestzeit je Level und Audio-Einstellungen.
  Keine Accounts, keine Cloud, keine Online-Funktionen.
- Der Bonus-Modus "Sammler" ist aus dem Menü erreichbar; die Szene des ersten
  Meilensteins bleibt vollständig funktionsfähig.

## 8. Technik und Struktur

- Kleine Szenen und Skripte mit klaren Node-Namen, lose Kopplung über Signale.
- Keine generischen Manager oder Frameworks, die das Spiel nicht braucht.
- Level-Aufbau und Gegnerwellen datengetrieben bzw. zentral konfigurierbar,
  ohne neuen Dateityp, wenn eine Konstante oder ein Szenenexport genügt.
- Headless lauffähig: keine Abhängigkeit von Maus, Auflösung oder Fenster.
- Das Projekt lädt ohne Parser-, Import- oder Szenenfehler.

## 9. Qualität und Prüfung

- Lade den Skill godot-pruefen und führe `./tools/check-project.sh` aus, bis
  er fehlerfrei durchläuft.
- Erweitere die headless Tests so, dass mindestens geprüft werden: Sprung und
  Landung, Doppelsprung, Checkpoint-Respawn, Chip-Einsammeln, Tod durch Gefahr,
  Levelende am Terminal, Speichern und Laden der Bestzeit, Pause und Fortsetzen.
- Prüfe mindestens ein Level headless über mehrere Sekunden auf Laufzeitfehler.
- Behebe selbst verursachte Parser-, Szenen-, Import- und Laufzeitfehler vor
  dem Abschluss.
- Dokumentiere in der Übergabe, welche Assets woher stammen, welche Effekte
  aktiv sind und wie man sie bei Performance-Problemen abschaltet.

## 10. Nicht Teil dieses Meilensteins

- Mehr als drei Level, Level-Editor, Zufallsgenerator.
- Online-Funktionen, Accounts, Cloud-Speicher, Ranglisten.
- Mobile- oder Konsolenexporte.
- C# oder zusätzliche Engine-Plugins.
- Kostenpflichtige oder unklar lizenzierte Assets.

## 11. Definition of Done

Der Meilenstein ist fertig, wenn:

- das Projekt headless ohne Fehler lädt und alle Level fehlerfrei starten,
- alle drei Level vom Start bis zum Terminal spielbar sind,
- Laufen, Springen, Doppelsprung, Checkpoints, Tode, Respawn, Pause und
  Neustart funktionieren,
- der Endgegner im dritten Level funktioniert,
- der Cyberpunk-Look mit echten Assets, Glow, Parallax, Animationen, Neon und
  Partikeln sichtbar ist und das Gameplay lesbar bleibt,
- Soundeffekte und Musik laufen und über die Einstellungen steuerbar sind,
- Bestzeiten und Audio-Einstellungen lokal gespeichert und wieder geladen werden,
- `assets/CREDITS.md` jede Asset-Herkunft mit Lizenz nennt,
- `./tools/check-project.sh` inklusive der erweiterten Logiktests erfolgreich ist,
- `AGENT_HANDOFF.md` den Stand korrekt beschreibt.

Nach der Implementierung: Lade den Skill godot-pruefen, führe alle Prüfungen aus
und behebe gefundene Fehler. Lade anschließend den Skill uebergabe-pflegen und
aktualisiere AGENT_HANDOFF.md.
```
