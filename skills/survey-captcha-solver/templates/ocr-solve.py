#!/usr/bin/env python3
"""
OCR CAPTCHA Solver — Tesseract-based
Usage: python3 ocr-solve.py <base64_screenshot_string>
Output: {"captcha": "ABC123", "confidence": 0.85}
"""
import sys, base64, json
from PIL import Image
import pytesseract

def solve_captcha(base64_png):
    try:
        img = Image.open(base64.b64decode(base64_png))
        # Tesseract with whitelist — CAPTCHAs are usually uppercase alphanumeric
        config = '--psm 8 -c tessedit_char_whitelist=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
        text = pytesseract.image_to_string(img, config=config).strip().upper()
        # Confidence estimation: length match heuristic
        confidence = min(1.0, len(text) / 6) if text else 0.0
        return {"captcha": text, "confidence": confidence, "ok": bool(text)}
    except Exception as e:
        return {"captcha": "", "confidence": 0, "ok": False, "error": str(e)}

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(json.dumps({"error": "Usage: ocr-solve.py <base64_png>"}))
        sys.exit(1)
    result = solve_captcha(sys.argv[1])
    print(json.dumps(result))
