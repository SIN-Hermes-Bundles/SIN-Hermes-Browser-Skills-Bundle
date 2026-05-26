---
name: survey-captcha-solver
description: Universal CAPTCHA solving for Heypiggy surveys using solve_captcha.py instead of slow browser_vision
title: Survey CAPTCHA Solver
version: 1.0
---

## Trigger
- CAPTCHA erscheint auf Survey-Seite (Text-CAPTCHA, Slider, Drag-Drop)
- browser_vision ist langsam (60-120s) und unzuverlässig
- CAPTCHA blockiert Survey-Fortschritt

## Regel
**Für CAPTCHA: Immer solve_captcha.py nutzen. Nie browser_vision für CAPTCHA-Lesung.**

## Warum solve_captcha.py statt browser_vision?

| Methode | Dauer | Erfolgsrate | Problem |
|---------|-------|-------------|---------|
| browser_vision | 60-120s | Niedrig | Langsam, 502-fällig, teuer |
| solve_captcha.py | 2-5s | Hoch | Lokal, schnell, deterministisch |

## Verwendung

```bash
# Automatisch erkennen und lösen
python3 ~/stealth-runner/survey-cli/survey/skills/solve_captcha.py auto

# Oder direkt per Typ:
python3 ~/stealth-runner/survey-cli/survey/skills/solve_captcha.py vision
python3 ~/stealth-runner/survey-cli/survey/skills/solve_captcha.py slider
python3 ~/stealth-runner/survey-cli/survey/skills/solve_captcha.py drag
```

## Ablauf nach CAPTCHA-Lösung

1. solve_captcha.py gibt JSON zurück: {"captcha": "YACEef", "ok": true}
2. Antwort in Input-Feld tippen: browser_type mit Wert
3. Weiter klicken: browser_click auf Nächste/Weiter
4. Snapshot: browser_snapshot prüfen ob weitergegangen

## Beispiel-Flow

```
browser_snapshot → CAPTCHA erkannt
→ solve_captcha.py auto (2s)
→ browser_type "captcha_text" (0.3s)
→ browser_click "Nächste" (0.3s)
→ browser_snapshot prüfen (0.3s)
= 3s total statt 90s mit browser_vision
```

## Verboten
- ❌ browser_vision für CAPTCHA-Lesung (zu langsam)
- ❌ browser_cdp Input.dispatchMouseEvent für Drag (fehleranfällig)
- ❌ Manueller JS-Drag in browser_console (komplex, bricht oft)

## Erforderlich
- cd ~/stealth-runner/survey-cli vor Ausführung
- Chrome auf Port 9999 läuft
- FIREWORKS_AI_API_KEY gesetzt

## Was funktioniert
- Text-CAPTCHA: solve_captcha.py vision (screenshot + OCR)
- Slider: solve_captcha.py slider (JS-Drag)
- Drag-Drop: solve_captcha.py drag (CDK-Drag)

## Was NICHT funktioniert
- reCAPTCHA iframe (unsichtbar für CDP-JS)
- Audio-CAPTCHA (nicht implementiert)
