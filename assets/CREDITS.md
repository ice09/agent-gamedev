# Asset-Quellen und Lizenzen

Alle Assets in diesem Projekt sind entweder selbst erzeugt oder stehen unter
einer freien Lizenz. Kein Asset ohne dokumentierte Herkunft.

## Schriftarten

| Datei | Quelle | Lizenz |
| --- | --- | --- |
| `assets/fonts/Rajdhani-Bold.ttf` | Google Fonts, Familie Rajdhani (Indian Type Foundry) | SIL Open Font License 1.1 (`assets/fonts/OFL-Rajdhani.txt`) |
| `assets/fonts/Rajdhani-Regular.ttf` | Google Fonts, Familie Rajdhani (Indian Type Foundry) | SIL Open Font License 1.1 (`assets/fonts/OFL-Rajdhani.txt`) |
| `assets/fonts/ShareTechMono-Regular.ttf` | Google Fonts, Familie Share Tech Mono (Carrois Apostrophe) | SIL Open Font License 1.1 (`assets/fonts/OFL-ShareTechMono.txt`) |

Bezogen über das offizielle Google-Fonts-Repository. Die Lizenztexte liegen bei.

## Selbst erzeugte Assets

Alles unter `assets/sprites/`, `assets/tiles/`, `assets/parallax/`, `assets/fx/`,
`assets/audio/` und `assets/icon.png` wurde im Projekt erzeugt und ist damit
originär. Es bestehen keine Rechte Dritter.

Erzeugt mit:

- `tools/generate_assets.py` (Pillow) – Pixel-Art, Tileset, Parallax, Partikel.
- `tools/generate_audio.py` (numpy, soundfile) – Soundeffekte als WAV, Musik
  als OGG.

Die Skripte sind deterministisch (feste Seeds) und erneut ausführbar. Sie
benötigen eine lokale virtuelle Umgebung, zum Beispiel:

```bash
python3 -m venv /tmp/assetvenv
/tmp/assetvenv/bin/pip install pillow numpy soundfile
/tmp/assetvenv/bin/python tools/generate_assets.py
/tmp/assetvenv/bin/python tools/generate_audio.py
```

## Nicht verwendete Quellen

Es wurden bewusst keine externen Asset-Pakete heruntergeladen. Der Cyberpunk-Look
entsteht vollständig aus den erzeugten Assets, Godot-Shadern, Glow, Partikeln und
Parallax-Ebenen.
