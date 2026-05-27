---
name: internal-captcha-discovery
description: Discover and use internal stealth-captcha solvers instead of searching GitHub
version: 1.0
---

# Internal CAPTCHA Solvers — Discovery Rule

**RULE:** Before searching GitHub for CAPTCHA solutions, ALWAYS check `stealth-captcha/src/stealth_captcha/solver/` first.

## Existing Solvers

| File | Type | Backend | Hermes-Ready? |
|------|------|---------|---------------|
| `text.py` | Text/OCR | Pixtral Large (NVIDIA NIM) | Needs Tesseract fallback (no API key) |
| `drag_drop_angular.py` | PureSpectrum "Zahl X" | CDP mouse events | Needs CDP port extraction |
| `slide.py` | Slider | CDP drag | ✅ Adaptable |
| `drag_drop.py` | Standard drag-drop | CDP drag | ✅ Adaptable |

## Key Architecture
- All solvers use `stealth_captcha.cdp.client.CDPSession` (async websocket)
- `text.py` has `VisionOCRBackend` Protocol — backends are swappable
- `PixtralLargeOCR` is the default but requires `NVIDIA_API_KEY`
- For Hermes: build `TesseractOCRBackend` implementing `VisionOCRBackend`

## BANNED (per AGENTS.md SR-260)
- ❌ 2Captcha, Capsolver, DeathByCaptcha, any paid service
- ❌ Searching GitHub before checking internal repo

## Hermes Integration Pattern
```python
# For text captcha via Hermes browser_cdp:
1. browser_cdp Page.captureScreenshot with clip rect
2. Save PNG to ~/captcha.png
3. terminal: tesseract ~/captcha.png stdout
4. browser_type into input field
5. browser_click submit

# For Angular drag-drop via Hermes browser_cdp:
1. Extract CDP port from browser_cdp connection
2. Use stealth-captcha logic with websocket directly
3. OR: browser_cdp Input.dispatchMouseEvent (mousedown → moves → mouseup)
```