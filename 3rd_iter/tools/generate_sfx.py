#!/usr/bin/env python3
"""Small original synthetic combat sounds, using only Python's standard library."""
import math
from pathlib import Path
import random
import struct
import wave

OUT = Path(__file__).resolve().parents[1] / "assets" / "audio"
RATE = 22050
SOUNDS = {
    "fire": (0.13, 950, 160),
    "impact": (0.11, 230, 65),
    "enemy_fire": (0.22, 150, 410),
    "shatter": (0.38, 420, 45),
    "repair": (0.34, 520, 1040),
    "hurt": (0.25, 180, 50),
}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    rng = random.Random(3)
    for name, (duration, start, end) in SOUNDS.items():
        frames = bytearray()
        phase = 0.0
        for index in range(int(RATE * duration)):
            t = index / RATE / duration
            phase += math.tau * (start + (end - start) * t) / RATE
            envelope = min(1.0, t * 35) * (1.0 - t) ** 2
            noise = rng.uniform(-1, 1) * (0.5 if name in ("impact", "shatter", "hurt") else 0.06)
            sample = (math.sin(phase) * 0.6 + math.sin(phase * 2.03) * 0.15 + noise) * envelope * 0.6
            frames.extend(struct.pack("<h", int(max(-1, min(1, sample)) * 32767)))
        with wave.open(str(OUT / f"{name}.wav"), "wb") as output:
            output.setnchannels(1)
            output.setsampwidth(2)
            output.setframerate(RATE)
            output.writeframes(frames)
    print("Generated six original combat WAVs")


if __name__ == "__main__":
    main()
