# CAPTCHA Image Isolation before Vision Send

## Problem (2026-05-27, PureSpectrum Survey)
`browser_vision` sent a full-page screenshot to the LLM. The vision model saw the refresh/reload icon (↻) next to the CAPTCHA image and interpreted it as a digit "9", producing `CPr6rx9` instead of the actual CAPTCHA `CPr6rx`.

## Root Cause
UI chrome elements (buttons, icons, text) surrounding the CAPTCHA are interpreted as characters by the vision model, corrupting the OCR result.

## Fix: Isolate the CAPTCHA Image Element
Instead of sending the full screenshot, extract ONLY the CAPTCHA image using canvas:

```javascript
// CDP Runtime.evaluate mit target_id
const img = document.querySelector('img[src*="captcha"], img.captcha-image, img[alt*="CAPTCHA"]');
if (!img) return 'no captcha image found';

const canvas = document.createElement('canvas');
canvas.width = img.width;
canvas.height = img.height;
canvas.getContext('2d').drawImage(img, 0, 0);
const croppedB64 = canvas.toDataURL('image/png');
// croppedB64 is a clean data: URL with ONLY the CAPTCHA
```

Then send `croppedB64` to `vision_analyze` or `browser_vision` (if it supports data URLs).

## Alternative: Coordinate-based Crop
If `browser_vision` screenshot is the only option:
1. Get the CAPTCHA image's bounding box via `getBoundingClientRect()`
2. Mentally crop to those coordinates
3. Ask vision to "read ONLY the distorted text in the center, ignore all buttons, icons, and labels"

## Verification
- Vision should now return ONLY the CAPTCHA characters, no suffix digits
- If the result includes a digit at the end that looks like an icon/button → still not isolated
