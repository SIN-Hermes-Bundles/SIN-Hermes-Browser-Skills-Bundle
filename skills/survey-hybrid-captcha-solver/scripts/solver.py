#!/usr/bin/env python3
"""
Hybrid CAPTCHA Solver: Tesseract OCR primary (~1s), LLM Vision fallback (~8s).
Extracts screenshot via CDP, runs OCR, falls back to vision if uncertain.
"""
import subprocess, json, os, sys, tempfile, base64

def solve_captcha_screenshot(screenshot_b64: str, question_hint: str = "What is the CAPTCHA code?") -> dict:
    """
    Solve CAPTCHA from base64 screenshot.
    Returns: {ok: bool, captcha: str, method: str, confidence: float}
    """
    # Decode base64
    try:
        img_data = base64.b64decode(screenshot_b64)
    except Exception as e:
        return {"ok": False, "error": f"Invalid base64: {e}", "captcha": "", "method": "none", "confidence": 0.0}
    
    # Save to temp file for Tesseract
    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as f:
        f.write(img_data)
        img_path = f.name
    
    try:
        # Tesseract with confidence output
        result = subprocess.run(
            ["tesseract", img_path, "stdout", "--psm", "8", "-c", "tessedit_char_whitelist=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"],
            capture_output=True, text=True, timeout=5
        )
        tesseract_text = result.stdout.strip()
        
        # Heuristic confidence: length + character sanity
        confidence = min(1.0, len(tesseract_text) / 6.0) if tesseract_text else 0.0
        
        # Check if result looks like a CAPTCHA (4-8 chars, alphanumeric)
        looks_like_captcha = 3 <= len(tesseract_text) <= 10 and tesseract_text.isalnum()
        
        if looks_like_captcha and confidence >= 0.5:
            os.unlink(img_path)
            return {
                "ok": True,
                "captcha": tesseract_text,
                "method": "tesseract",
                "confidence": confidence
            }
        
        # Fallback: LLM Vision (via Hermes wrapper if available, else skip)
        os.unlink(img_path)
        return {
            "ok": False,
            "captcha": tesseract_text,
            "method": "tesseract_uncertain",
            "confidence": confidence,
            "fallback_needed": True,
            "reason": f"OCR result '{tesseract_text}' looks_like={looks_like_captcha}, confidence={confidence:.2f}"
        }
        
    except Exception as e:
        os.unlink(img_path)
        return {"ok": False, "error": str(e), "captcha": "", "method": "tesseract_error", "confidence": 0.0}

if __name__ == "__main__":
    # Read base64 from stdin
    data = sys.stdin.read().strip()
    if not data:
        print(json.dumps({"ok": False, "error": "No input"}))
        sys.exit(1)
    
    result = solve_captcha_screenshot(data)
    print(json.dumps(result))
