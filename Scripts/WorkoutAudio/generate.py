#!/usr/bin/env python3
"""Generate the original one-second set-start cue; no external recordings."""
import math
from pathlib import Path
import struct
import wave

OUTPUT = Path(__file__).resolve().parents[2] / 'onlybody/onlybody/Resources/Sounds/rest-complete.wav'
SAMPLE_RATE = 44100
DURATION = 1.0
FREQUENCY = 1000.0
ATTACK_SECONDS = 0.025
RELEASE_SECONDS = 0.10

tones = []
for index in range(round(SAMPLE_RATE * DURATION)):
    time = index / SAMPLE_RATE
    # A single sustained sine tone, with soft edges and no sharp harmonics.
    attack = min(1.0, time / ATTACK_SECONDS)
    release = min(1.0, (DURATION - time) / RELEASE_SECONDS)
    envelope = math.sin(attack * math.pi / 2) ** 2 * math.sin(release * math.pi / 2) ** 2
    tones.append(math.sin(2 * math.pi * FREQUENCY * time) * envelope)

peak = max(abs(tone) for tone in tones)
samples = b''.join(struct.pack('<h', round(32767 * 0.9 * tone / peak)) for tone in tones)

OUTPUT.parent.mkdir(parents=True, exist_ok=True)
with wave.open(str(OUTPUT), 'wb') as output:
    output.setnchannels(1)
    output.setsampwidth(2)
    output.setframerate(SAMPLE_RATE)
    output.writeframes(samples)
print(f'Generated {OUTPUT.name}: {DURATION:.1f}s, {FREQUENCY:.0f} Hz sustained beep, mono PCM.')
