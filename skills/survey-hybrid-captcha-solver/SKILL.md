---
name: survey-hybrid-captcha-solver
title: Hybrid CAPTCHA Solver (Tesseract + LLM Vision Fallback)
description: Loesst CAPTCHA in ~1.5s statt 8s. Tesseract OCR primary, LLM Vision fallback bei Unsicherheit.
version: 1.0.0
metadata:
  hermes:
    tags: [survey, captcha, ocr, vision, fast]
    category: survey
---

# Hybrid CAPTCHA Solver

## Speed Comparison
| Methode | Zeit | Nutzen |
|---------|------|--------|
| Tesseract OCR | ~1.2s | Kostenlos, lokal |
| LLM Vision | ~8s | Teuer, langsam |
| **Hybrid (dieser Skill)** | **~1.5s** | Best of both |

## Flow
1. **Screenshot** via `browser_cdp` oder `browser_vision` (macht Bild)
2. **Tesseract OCR** auf dem Screenshot (lokal, ~1s)
3. **Confidence Check**: Ist Ergebnis 4-10 Zeichen, alphanumerisch?
4. **Ja** → Direkt zurueckgeben (1.2s total)
5. **Nein** → `vision_analyze` als Fallback (~8s, aber nur bei Bedarf)

## Hermes Tool-Calls (Beispiel)

### Step 1: Screenshot + OCR
```javascript
// CDP: Screenshot als base64
browser_cdp Runtime.evaluate:
  expression: `
    (async () => {
      const data = await new Promise(r => chrome.runtime.sendMessage({action:'captureVisibleTab'}, r));
      return data;
    })()
  `
```

Oder einfacher: `browser_vision` macht das Bild implizit, dann OCR:

```bash
cat screenshot.b64 | python3 hybrid_captcha_solver.py
```

### Step 2: LLM Fallback (nur wenn OCR unsicher)
```
vision_analyze(image_url=screenshot_path, question="Read the CAPTCHA code")
```

## Python Script

Speicherort: `~/.hermes/skills/survey/survey-hybrid-captcha-solver/scripts/solver.py`

Input: base64 PNG via stdin
Output: JSON `{ok: true, captcha: "Y7X9", method: "tesseract", confidence: 0.85}`

## Trigger
- CAPTCHA erscheint auf Survey-Seite
- `browser_vision` wuerde 8s dauern
- Stattdessen: Tesseract zuerst, dann nur bei Unsicherheit Vision

## Was funktioniert
- Text-CAPTCHA (Buchstaben/Zahlen)
- Einfache Bild-CAPTCHA

## Was NICHT funktioniert
- reCAPTCHA v2 (iframe, detected by Google)
- Audio-CAPTCHA

## Speed-Optimierung fuer Surveys
- Tesseract ist installiert auf macOS via Homebrew: `/opt/homebrew/bin/tesseract`
- Alternative: `/usr/local/bin/tesseract`
- PSM 8 (single word mode) fuer CAPTCHA-Optimierung
- `tessedit_char_whitelist` beschraenkt auf alphanumerisch

## Integration in Survey Flow
```
1. browser_snapshot -> CAPTCHA erkannt
2. browser_cdp -> screenshot base64
3. terminal: echo <b64> | python3 solver.py -> JSON
4. Wenn ok: browser_type captcha_text
5. Wenn fallback_needed: vision_analyze -> captcha_text
6. browser_click "Weiter"
```

## Performance
- Tesseract allein: ~1.16s
- Mit base64 decode + JSON parse: ~1.3s
- Mit Hermes Tool-Overhead: ~1.5-2.0s
- vs browser_vision: ~8s (75% schneller!)
