---
name: heypiggy-purespectrum-captcha-extract
title: PureSpectrum CAPTCHA Bild-Extraktion
description: Extrahiert Base64-CAPTCHA-Bilder aus PureSpectrum-Umfragen über FileReader + Chunks
---

# PureSpectrum CAPTCHA Bild-Extraktion

## Problem
PureSpectrum zeigt bei ~50% ein Text-CAPTCHA (Base64 PNG). Die Base64-Daten sind ~6342 Zeichen lang und werden von CDP trunciert.

## Lösung
1. Bild finden: `document.querySelectorAll('img')[1]` (Index 1 ist CAPTCHA, Index 0 ist Logo)
2. FileReader verwenden, um Blob in Base64 zu konvertieren
3. Base64 in Chunks à 500 Zeichen teilen
4. Chunks URI-encoden und in `window.__captchaChunks` speichern
5. Chunks über `Runtime.evaluate` abrufen
6. In Python: URI-decode, Base64-decode, PNG speichern
7. Tesseract OCR mit `--psm 8 --oem 3`

## CDP Code (JavaScript im Browser)
```javascript
(async function() {
  var img = document.querySelectorAll('img')[1];
  var response = await fetch(img.src);
  var blob = await response.blob();
  var reader = new FileReader();
  
  return new Promise(function(resolve) {
    reader.onloadend = function() {
      var base64 = reader.result;
      var chunks = [];
      for(var i=0; i<base64.length; i+=500) {
        chunks.push(encodeURIComponent(base64.substring(i, i+500)));
      }
      window.__captchaChunks = chunks;
      resolve(JSON.stringify({
        totalLength: base64.length,
        numChunks: chunks.length
      }));
    };
    reader.readAsDataURL(blob);
  });
})()
```

## Python (Chunks zusammensetzen + OCR)
```python
import base64, urllib.parse, subprocess, os

# chunks = [...]  # von CDP
full_base64 = ''.join([urllib.parse.unquote(c) for c in chunks])
base64_data = full_base64.split(',')[1]  # remove data:image/png;base64,
img_bytes = base64.b64decode(base64_data)
home_path = os.path.expanduser('~/captcha.png')
with open(home_path, 'wb') as f:
    f.write(img_bytes)
result = subprocess.run(
    ['tesseract', home_path, 'stdout', '--psm', '8', '--oem', '3',
     '-c', 'tessedit_char_whitelist=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'],
    capture_output=True, text=True
)
print(result.stdout.strip())
```

## Wichtig
- Tesseract kann /tmp NICHT lesen → IMMER ins Home-Verzeichnis speichern
- `--psm 8` = single word mode
- `--oem 3` = LSTM only
- Wenn OCR inkonsistent (verschiedene Ergebnisse bei verschiedenen Runs): CAPTCHA zuverlässig nicht lösbar → Umfrage abbrechen

## Beobachtung
PureSpectrum CAPTCHA-Bilder sind 150×50 PNG mit sehr niedrigem Kontrast. Tesseract allein ist nicht zuverlässig genug — Ergebnisse schwanken stark (ERAS/YEAS/E34As/JER4AS/YE34AS bei verschiedenen Preprocessing-Läufen auf demselben Bild).

## OCR Strategy (Cross-Check)
1. **Tesseract first** (`--psm 8 --oem 3`) — schnell, lokal
2. **If inconsistent across preprocessing variants** → **EasyOCR cross-check**

```bash
pip install easyocr
python3 -c "
import easyocr
reader = easyocr.Reader(['en'], gpu=False)
result = reader.readtext('/Users/USER/captcha.png', detail=0)
print(result)
"
```

3. **If Tesseract ≠ EasyOCR** → **abort survey** (never guess)
4. **Only proceed if both engines agree** OR Tesseract is consistent across 3+ preprocessing variants

## FileReader vs. direct src access
Direct `img.src` Base64 strings get truncated by CDP (~6000 chars max). Always use `FileReader.readAsDataURL(blob)` → chunk into ~500-char URI-encoded strings → reassemble in Python.