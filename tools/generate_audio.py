#!/usr/bin/env python3
"""Erzeugt Soundeffekte (WAV) und Musik (OGG) fuer Neon Rush.

Benoetigt numpy und soundfile:
    python3 -m venv /tmp/assetvenv
    /tmp/assetvenv/bin/pip install numpy soundfile
    /tmp/assetvenv/bin/python tools/generate_audio.py
"""
from __future__ import annotations

import os

import numpy as np
import soundfile as sf

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SR = 44100
rng = np.random.default_rng(42)


def out(*parts: str) -> str:
    path = os.path.join(ROOT, *parts)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    return path


def t_axis(seconds: float) -> np.ndarray:
    return np.linspace(0.0, seconds, int(SR * seconds), endpoint=False)


def adsr(n: int, a: float, d: float, s: float, r: float, sustain: float = 0.7) -> np.ndarray:
    env = np.zeros(n)
    ai = min(int(a * SR), n)
    di = min(int(d * SR), n - ai)
    ri = min(int(r * SR), n - ai - di)
    si = n - ai - di - ri
    idx = 0
    if ai:
        env[idx:idx + ai] = np.linspace(0, 1, ai)
        idx += ai
    if di:
        env[idx:idx + di] = np.linspace(1, sustain, di)
        idx += di
    if si:
        env[idx:idx + si] = sustain
        idx += si
    if ri:
        env[idx:idx + ri] = np.linspace(sustain, 0, ri)
    return env


def sine(f: np.ndarray, t: np.ndarray) -> np.ndarray:
    return np.sin(2 * np.pi * f * t)


def square(f: np.ndarray, t: np.ndarray) -> np.ndarray:
    return np.sign(np.sin(2 * np.pi * f * t))


def saw(f: np.ndarray, t: np.ndarray) -> np.ndarray:
    return 2.0 * (t * f - np.floor(0.5 + t * f))


def triangle(f: np.ndarray, t: np.ndarray) -> np.ndarray:
    return 2.0 * np.abs(2.0 * (t * f - np.floor(t * f + 0.5))) - 1.0


def midi(m: float) -> float:
    return 440.0 * 2.0 ** ((m - 69) / 12.0)


def sweep(f0: float, f1: float, n: int) -> np.ndarray:
    return np.linspace(f0, f1, n)


def norm(x: np.ndarray, peak: float = 0.85) -> np.ndarray:
    m = np.max(np.abs(x)) or 1.0
    return x / m * peak


def write_wav(path: str, x: np.ndarray) -> None:
    sf.write(path, np.clip(x, -1, 1).astype(np.float32), SR, subtype="PCM_16")
    print("geschrieben:", os.path.relpath(path, ROOT))


def write_ogg(path: str, left: np.ndarray, right: np.ndarray) -> None:
    stereo = np.stack([np.clip(left, -1, 1), np.clip(right, -1, 1)], axis=1)
    sf.write(path, stereo.astype(np.float32), SR, format="OGG", subtype="VORBIS")
    print("geschrieben:", os.path.relpath(path, ROOT))


def blip(f0: float, f1: float, dur: float, kind: str = "square", vol: float = 0.7) -> np.ndarray:
    n = int(SR * dur)
    t = np.arange(n) / SR
    f = sweep(f0, f1, n)
    wave = {"square": square, "saw": saw, "sine": sine, "tri": triangle}[kind](f, t)
    return norm(wave * adsr(n, 0.005, dur * 0.3, 0.5, dur * 0.4), vol)


def noise_burst(dur: float, vol: float = 0.8, highpass: bool = False) -> np.ndarray:
    n = int(SR * dur)
    x = rng.normal(0, 1, n)
    if highpass:
        x = np.diff(np.concatenate([[0.0], x]))
    return norm(x * adsr(n, 0.001, dur * 0.4, 0.3, dur * 0.5), vol)


def mix(*parts: np.ndarray) -> np.ndarray:
    n = max(len(p) for p in parts)
    buf = np.zeros(n)
    for p in parts:
        buf[:len(p)] += p
    return buf


def build_sfx() -> None:
    write_wav(out("assets", "audio", "click.wav"), noise_burst(0.05, 0.5, True))
    write_wav(out("assets", "audio", "jump.wav"), blip(240, 760, 0.20, "square"))
    write_wav(out("assets", "audio", "land.wav"),
              mix(blip(180, 90, 0.14, "sine", 0.8), noise_burst(0.08, 0.35)))
    write_wav(out("assets", "audio", "chip.wav"),
              mix(blip(880, 880, 0.07, "square", 0.5), blip(1320, 1320, 0.10, "square", 0.5)))
    write_wav(out("assets", "audio", "checkpoint.wav"),
              mix(blip(523, 523, 0.25, "tri", 0.5), blip(659, 659, 0.30, "tri", 0.4),
                  blip(784, 784, 0.40, "tri", 0.4)))
    write_wav(out("assets", "audio", "hit.wav"),
              mix(noise_burst(0.28, 0.7), blip(420, 120, 0.28, "saw", 0.6)))
    write_wav(out("assets", "audio", "death.wav"),
              mix(blip(440, 70, 0.65, "saw", 0.7), noise_burst(0.5, 0.3)))
    write_wav(out("assets", "audio", "complete.wav"),
              mix(blip(523, 523, 0.14, "square", 0.5), blip(659, 659, 0.30, "square", 0.5),
                  blip(784, 784, 0.42, "square", 0.5), blip(1046, 1046, 0.80, "square", 0.5)))
    print("SFX fertig.")


def kick() -> np.ndarray:
    n = int(SR * 0.22)
    t = np.arange(n) / SR
    f = sweep(140, 42, n)
    return norm(sine(f, t) * adsr(n, 0.002, 0.12, 0.1, 0.09), 0.9)


def snare() -> np.ndarray:
    return noise_burst(0.16, 0.6, True)


def hat() -> np.ndarray:
    return noise_burst(0.05, 0.25, True)


def note(freq: float, dur: float, kind: str = "saw", vol: float = 0.4,
         a: float = 0.01, d: float = 0.1, s: float = 0.6, r: float = 0.08) -> np.ndarray:
    n = int(SR * dur)
    t = np.arange(n) / SR
    f = np.full(n, freq, dtype=float)
    wave = {"square": square, "saw": saw, "sine": sine, "tri": triangle}[kind](f, t)
    return wave * adsr(n, a, d, s, r) * vol


def detuned(freq: float, dur: float, kind: str, vol: float) -> np.ndarray:
    return note(freq, dur, kind, vol) + note(freq * 1.006, dur, kind, vol * 0.7)


def place(buf: np.ndarray, clip: np.ndarray, at: float) -> None:
    i = int(at * SR)
    end = min(len(buf), i + len(clip))
    if i < len(buf):
        buf[i:end] += clip[:end - i]


def delay(x: np.ndarray, time_s: float, feedback: float, mix_amt: float) -> np.ndarray:
    d = int(time_s * SR)
    y = x.copy()
    i = d
    while i < len(y):
        y[i:] += y[i - d:len(y) - d] * feedback
        i += d
    return x * (1 - mix_amt) + y * mix_amt


# A-Moll: Am - F - C - G
PROG = [[57, 60, 64], [53, 57, 60], [48, 52, 55], [55, 59, 62]]


def synth_track(bpm: float, bars: int, style: str, seed: int) -> tuple[np.ndarray, np.ndarray]:
    beat = 60.0 / bpm
    total = beat * 4 * bars
    n = int(SR * total)
    lead = np.zeros(n)
    bass = np.zeros(n)
    pad = np.zeros(n)
    drums = np.zeros(n)
    r = np.random.default_rng(seed)

    for bar in range(bars):
        chord = PROG[bar % len(PROG)]
        t0 = bar * 4 * beat
        root = chord[0]
        # Bass: Achtel
        for k in range(8):
            place(bass, note(midi(root - 12), beat * 0.45, "saw", 0.5,
                             a=0.004, d=0.08, s=0.5, r=0.05), t0 + k * beat * 0.5)
        # Pad: Akkord
        for m in chord:
            place(pad, detuned(midi(m), beat * 3.8, "tri", 0.11), t0)
        # Arp
        steps = 8 if style == "menu" else 16
        for k in range(steps):
            m = chord[k % len(chord)] + 12 * (1 + (k // len(chord)) % 2)
            vol = 0.20 if style == "menu" else 0.26
            place(lead, note(midi(m), beat * 0.45, "square", vol,
                             a=0.004, d=0.06, s=0.4, r=0.04), t0 + k * (4 * beat / steps))
        # Drums
        if style != "menu":
            for b in range(4):
                place(drums, kick(), t0 + b * beat)
                if b in (1, 3):
                    place(drums, snare(), t0 + b * beat)
            for k in range(8):
                place(drums, hat(), t0 + k * beat * 0.5)
        else:
            place(drums, kick(), t0)
    if style == "boss":
        for k in range(bars * 8):
            place(lead, note(midi(PROG[k % 4][0] + 24), beat * 0.22, "saw", 0.18), k * beat * 0.5)
    lead = delay(lead, beat * 0.75, 0.35, 0.35)
    left = mix(bass * 0.9, pad * 0.85, lead * 0.8, drums * 0.7)
    right = mix(bass * 0.9, pad * 0.9, delay(lead, beat * 0.5, 0.3, 0.5) * 0.8, drums * 0.7)
    # Enden ausblenden, damit der Loop sauber klingt
    fade = int(SR * 0.08)
    left[-fade:] *= np.linspace(1, 0, fade)
    right[-fade:] *= np.linspace(1, 0, fade)
    return norm(left, 0.7), norm(right, 0.7)


def build_music() -> None:
    menu = synth_track(96, 8, "menu", 1)
    write_ogg(out("assets", "audio", "music_menu.ogg"), *menu)
    level = synth_track(128, 8, "level", 2)
    write_ogg(out("assets", "audio", "music_level.ogg"), *level)
    boss = synth_track(150, 8, "boss", 3)
    write_ogg(out("assets", "audio", "music_boss.ogg"), *boss)
    print("Musik fertig.")


if __name__ == "__main__":
    build_sfx()
    build_music()
