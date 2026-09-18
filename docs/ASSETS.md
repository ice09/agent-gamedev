# Assets mit KI erstellen (ChatGPT & Co.)

Alle Assets in diesem Template entstehen ohne gekaufte Packs, auf zwei Wegen:
**A. Chatmodell** für Entwürfe und Referenzen (Charakter, Gegner, Levelideen),
**B. Code** für die finalen Spieldateien (SVG-Ebenen, synthetisierte Sounds).
Jedes übernommene Asset bekommt einen Eintrag in der passenden `CREDITS.md`.

## Weg A: Charakter und Gegner per Chatmodell entwerfen

So sind die Beispiele hier entstanden: Dem Bildmodell wurde zuerst eine
verbindliche Referenz beschrieben, danach erst Posen und Details.

1. **Master-Referenz erzeugen.** Ein Bild mit Figur, Details, Material und
   Palette anfordern. Beispiel-Prompt (anpassen!):

   ```text
   Character reference sheet for a 2D side-scroller, cyberpunk operative:
   middle-aged man, receding hair, black rectangular glasses, long dark
   tactical coat, shoulder armour, utility belt, heavy boots, violet
   technology glow strips, translucent holographic coat panels.
   Strict side view, orthographic, neutral background, no perspective,
   no cinematic angle. Include a labeled color palette.
   ```

   Abgelegte Beispiele: `1st_iter/docs/art/character_bible/`
   (`player_master_reference.png`, `player_turnaround.png`,
   `player_keyposes.png`, `player_poses.png`,
   `player_character_bible.png`).
2. **Palette festschreiben.** Hex-Werte aus dem Referenzbild in eine
   `player_palette.md` übertragen. Beispiel:
   `1st_iter/docs/art/character_bible/player_palette.md`
   (schwarz `#0A0A0A`, violett `#8A5CFF`, Haut `#D9A98C`, …).
3. **Unverrückbare Regeln notieren.** Was das Modell nie ändern darf
   (Gesicht, Brille, Silhouette, Akzentfarben). Beispiel:
   `1st_iter/docs/art/ART_DIRECTION.md` – jedem weiteren Prompt beilegen.
4. **Gegner gleich behandeln.** Erst Design-Brief, dann Bild. Beispiel:
   `3rd_iter/ENEMIES.md` (Schienenbeißer, Augenqualle, Lückenchor,
   Nullkantor).

Wichtig: Referenzbilder sind **keine Sprites**. Niemals das ganze Blatt *IN*
das Spiel kopieren oder Figuren aus Concept-Art ausschneiden – sie sind nur
Vorlage für separate, animierbare Spielfiguren (siehe `2nd_iter/CHARACTER.md`).

## Weg B: Spielfertige Dateien per Code erzeugen

Deterministisch, ohne Modellkosten, erneut ausführbar:

- **Umgebung in Ebenen:** `dist/level1/tools/generate_art.py` erzeugt sechs
  getrennte SVGs (Himmel, Skyline, Türme, Infrastruktur, Plattformen, Dach).
  Parallax-Faktoren 0.05 / 0.15 / 0.35 / 0.60, Gameplay-Layer 1.00. Ebenen
  halten statt eines fertigen Levelbilds – so bleibt Parallax möglich.
- **Sounds synthetisieren:** `3rd_iter/tools/generate_sfx.py` erzeugt sechs
  WAV-Effekte nur mit der Python-Standardbibliothek. Root-Beispiel mit
  Musik: `tools/generate_audio.py` (braucht `numpy`, `soundfile`).
- **Pixel-Art-Alternative:** `tools/generate_assets.py` (Pillow) für Tiles,
  Parallax und Partikel im Root-Projekt.

## Level-Brief schreiben

Ein guter Level-Brief nennt Ort, begehbare Elemente, Licht, Tiefe und
Ausschlüsse – kein fertiges Bild. Beispiel komplett:
`level1.md`. Master-Prompt für Umgebungen (Englisch, stabiler für Bildmodelle):
`1st_iter/docs/art/environment_bible/MASTER_ENVIRONMENT_PROMPT.md`, dazu die
Ebenen-Tabelle in `1st_iter/docs/art/environment_bible/README.md`.

Kurz-Vorlage für einen eigenen Environment-Prompt:

```text
[MASTER-PROMPT einfügen]
ASSET: [Objekt oder Ebene]
LAYER: [Himmel / fern / mittel / nah / Gameplay / Vordergrund]
OUTPUT: [Größe, Format, Transparenz, Kachelbarkeit]
TRAVERSAL: [begehbare Flächen oder nur Deko]
Exclude characters, captions, UI, and watermarks.
Deliver this layer separately; do not flatten the complete level.
```

## Checkliste vor Übernahme ins Spiel

- Passt die Silhouette bei Spielgröße (Figur ca. 180 px bei 1280×720)?
- Bleibt der Gameplay-Layer lesbar vor dem Hintergrund?
- Sind Ebenen, Kollision und Effekte getrennt?
- Steht die Herkunft in `CREDITS.md` (Modell, Datum, Prompt-Kurzform)?
- Keine Wasserzeichen, keine fremden Figuren, keine UI im Asset?

## Rechte-Hinweis (keine Rechtsberatung)

Eigene Generierungen aus eigenen Prompts sind hier als eigene Assets
dokumentiert. Vor Veröffentlichung prüfen: Nutzungsbedingungen des
verwendeten Modells, keine marken- oder personengeschützten Vorlagen
verlangen, Fonts nur mit OFL-Lizenztext übernehmen (Beispiel:
`assets/fonts/` + `assets/CREDITS.md`).
