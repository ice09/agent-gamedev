# Spielspezifikation

## Ziel

Ein sehr kleines, vollständiges 2D-Spiel mit einer verständlichen Spielschleife. Der erste Meilenstein priorisiert Spielbarkeit und robuste Technik, nicht visuelle Perfektion.

## Erster spielbarer Meilenstein

- Die Spielfigur bewegt sich mit WASD und Pfeiltasten.
- Sammelobjekte erscheinen im Spielfeld.
- Das Einsammeln erhöht den sichtbaren Punktestand.
- Gegner oder Gefahren bewegen sich durch das Spielfeld.
- Eine Berührung mit einer Gefahr beendet die Runde.
- Die Runde kann per Tastendruck oder UI-Schaltfläche neu gestartet werden.
- Platzhaltergrafiken aus Godot-Primitiven genügen.
- Es werden keine externen Assets benötigt.

## Qualitätsziele

- Das Projekt lässt sich ohne Parser-, Import- oder Szenenfehler laden.
- Die Hauptszene startet direkt über `project.godot`.
- Logik und Darstellung bleiben einfach und nachvollziehbar.
- Einstellbare Werte wie Geschwindigkeit oder Spawn-Zeit liegen zentral und klar benannt.
- Texte und Bedienelemente sind zunächst deutsch.

## Nicht Teil des ersten Meilensteins

- Online-Funktionen
- Persistente Accounts oder Cloud-Speicher
- komplexe Inventar-, Quest- oder Dialogsysteme
- externe Plugins
- finale Grafiken, Musik oder Animationen
- Mobile- oder Konsolenexporte

## Definition of Done

Der Meilenstein ist fertig, wenn das Spiel startet, die vollständige Runde spielbar ist, ein Neustart funktioniert, der Godot-Prüflauf erfolgreich ist und `AGENT_HANDOFF.md` den aktuellen Stand korrekt beschreibt.

