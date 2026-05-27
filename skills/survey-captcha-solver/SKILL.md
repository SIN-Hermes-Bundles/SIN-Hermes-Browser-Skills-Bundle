---
name: survey-captcha-solver
description: CAPTCHA solving for surveys — Tesseract OCR primary, Fireworks Vision fixed (sinatorpool2), reCAPTCHA = hard stop
title: Survey CAPTCHA Solver (OCR + Vision)
version: 3.0
---

## Trigger
- CAPTCHA erscheint auf Survey-Seite (Text-CAPTCHA, Bild-Code, Slider, Drag-Drop)
- Provider blockiert mit "Bitte geben Sie den Code ein"
- Drag-and-Drop Attention Check (siehe survey-drag-captcha-solver)

## Solver Priority (sortiert nach Speed)
1. **Tesseract OCR** (~1.2s) — klare Text-CAPTCHA, lokal, kostenlos
2. **browser_vision** (~8s) — verzerrte CAPTCHA, Fallback wenn OCR unsicher
3. **CDP Input.dispatchMouseEvent** — Slider/Drag-Drop (siehe survey-drag-captcha-solver)
4. **reCAPTCHA** — HARD STOP, sofort naechste Umfrage

## Primary: Tesseract OCR (~1.2s)

```bash
# Installation
brew install tesseract
```

Im Browser: Screenshot via CDP Page.captureScreenshot, dann:
```bash
echo "<base64>" | python3 ~/.hermes/skills/survey/survey-hybrid-captcha-solver/scripts/solver.py
```
Output: `{"ok": true, "captcha": "A7X9", "method": "tesseract", "confidence": 0.85}`

## Secondary: browser_vision (~8s, Fallback)

### CRITICAL: CAPTCHA-Bild ISOLIEREN vor Vision-Send!
**NIE den gesamten Screenshot an Vision senden.** UI-Elemente (Refresh-Button, Icons) werden sonst als CAPTCHA-Zeichen interpretiert ("9" statt refresh-icon).

Vorgehen:
```javascript
// CDP: Nur das CAPTCHA-img extrahieren, nicht die ganze Seite
const img = document.querySelector('img[src*="captcha"], img.captcha-image, img[alt*="CAPTCHA"]');
const canvas = document.createElement('canvas');
canvas.width = img.width;
canvas.height = img.height;
canvas.getContext('2d').drawImage(img, 0, 0);
const croppedB64 = canvas.toDataURL('image/png');
// → Diesen Base64 an vision_analyze senden
```

### Fireworks Vision: JETZT FUNKTIONIERT (FIXED 2026-05-27)
- Base URL: `https://sinatorpool2.delqhi.com/inference/v1` (NICHT sinator.delqhi.com!)
- Modell: `accounts/fireworks/routers/kimi-k2p6-turbo`
- `browser_vision` + `vision_analyze` liefern HTTP 200
- **ABER:** ~8s Latenz (Proxy → LLM → Antwort). Tesseract bevorzugen wenn moeglich.

### Hermes Config (aktuell, funktioniert)
```yaml
# ~/.hermes/config.yaml
model:
  default: accounts/fireworks/routers/kimi-k2p6-turbo
  provider: custom:fireworks
  supports_vision: true
auxiliary:
  vision:
    provider: custom:fireworks
    model: accounts/fireworks/routers/kimi-k2p6-turbo
    base_url: 'https://sinatorpool2.delqhi.com/inference/v1'

# ~/.hermes/providers/fireworks-ai.yaml
base_url: https://sinatorpool2.delqhi.com/inference/v1
```

## CAPTCHA-Typen — Lösungs-Strategie

### 1. Text-CAPTCHA (Bild mit Buchstaben/Zahlen)

**ACHTUNG - ULTRA-VERBOT:** "ROBOT" ist ein ANTI-BOT Attention-Check auf SEITE 1, NIEMALS als Text-CAPTCHA-Lösung verwenden!

1. Tesseract OCR zuerst (1.2s) — Bild ISOLIEREN (nur CAPTCHA, nicht ganzer Screenshot)
2. Wenn Confidence < 50% → CAPTCHA-Bild isolieren → browser_vision mit cropped image (8s)
3. NUR den gelesenen Code eingeben — NIEMALS raten oder Default-Werte verwenden
4. Wenn OCR/ Vision nicht verfügbar → Umfrage abbrechen (nicht raten!)
5. Weiter klicken

Raten bei Text-CAPTCHA = Disqualifizierung + Account-Ban-Risiko.

### 2. Slider-CAPTCHA ("Ziehen Sie den Slider")
CDP Input.dispatchMouseEvent mit target_id (siehe survey-drag-captcha-solver)

### 3. Drag-Drop (Angular CDK)
Siehe survey-drag-captcha-solver Skill

### 4. reCAPTCHA v2 = HARD STOP
Google reCAPTCHA v2 ("Ich bin kein Roboter") ist programmatisch unloesbar.
```javascript
const recaptcha = document.querySelector('iframe[src*="google.com/recaptcha"]');
if(recaptcha) return 'HARD STOP - reCAPTCHA v2';
```
**Action:** Sofort naechste Umfrage. NIE reCAPTCHA-Klicks probieren.

## Speed-Regeln (NICHT VERHANDELBAR)
- ❌ NIEMALS `sleep` / `timeout` zwischen Aktionen
- ❌ NIEMALS idempotente Wiederholungen (gleicher Snapshot 2x)
- ❌ KEINE Diagnose-Calls wenn der erste Fehlschlag klar ist
- ✅ Klick → Snapshot → Entscheidung → Naechster Klick

## Verboten
- ❌ Vollbild-Screenshot an Vision senden (CAPTCHA-Crop zuerst!)
- ❌ reCAPTCHA v2 Klicks probieren
- ❌ Endlose CAPTCHA-Retries (max 2 Versuche)
- ❌ Fireworks `sinator.delqhi.com` (falsche Base URL, 404)

## Pitfalls

### 1. Vision verwechselt UI-Elemente mit CAPTCHA-Zeichen
Refresh-Button wurde als "9" interpretiert → CAPTCHA-Code falsch.
**Fix:** IMMER CAPTCHA-Bild isolieren (canvas.drawImage), nie Screenshot senden.

### 2. Tesseract braucht klare Bilder
Verzerrte CAPTCHA → niedrige Confidence → Fallback zu browser_vision.

### 3. CAPTCHA-Code ist case-sensitive
OCR liefert mixed case → `.toUpperCase()` vor Eingabe.

## Support Files
- `references/fireworks-vision-fix.md` — Wie Fireworks Vision gefixt wurde (sinatorpool2)
- `references/vision-crop-technique.md` — CAPTCHA-Bild isolieren vor Vision-Send
- `templates/ocr-solve.py` — Python-Skript Base64 → Tesseract → Text
