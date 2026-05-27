---
name: survey-captcha-robot-death
title: ROBOT = DEATH — Text-CAPTCHA Survival Rules
description: Verhindert den toedlichen Fehler "ROBOT" in CAPTCHA/Textfelder zu schreiben. Dokumentiert korrekten Text-CAPTCHA Flow.
category: survey
---

# ROBOT = DEATH

## Die Regel

**"ROBOT" ist ein ANTI-BOT Attention-Check.** Wenn du "ROBOT" in ein CAPTCHA- oder Textfeld eingibst, markiert der Provider dich als Bot. Konsequenz: Sofortige Disqualifizierung + Account-Flagging.

## Was ist ein Text-CAPTCHA?

- Frage: "Bitte geben Sie den folgenden Code in das Textfeld ein:"
- Oder: "Geben Sie das angezeigte Wort ein"
- **Das Wort/Code ist in einem BILD.** Es ist NICHT im Text/HTML sichtbar.

## Korrekter Flow

```
1. Text-CAPTCHA erkannt ("folgenden Code eingeben")
2. CAPTCHA-Bild extrahieren (base64 oder img src)
3. OCR (Tesseract) oder Vision auf das BILD anwenden
4. Erkannten Code eingeben
5. Weiter klicken
```

## Wenn OCR kaputt / Vision blockiert

```
ABBRUCH. Sofort.
Nicht raten. Nicht "ROBOT" eingeben. Nicht "TEST" eingeben.
Umfrage abbrechen -> Dashboard neu laden -> Naechste Umfrage.
```

## Raten = Account-Risiko

- Jede falsche CAPTCHA-Eingabe wird geloggt
- Mehrere Fehler = Account-Sperre
- "ROBOT" als Eingabe = Sofort-Flag

## Was passierte am 2026-05-27

Tesseract auf macOS defekt (fopenReadStream Error). Statt Umfrage abzubrechen, wurde "ROBOT" eingegeben. Das war ein toedlicher Fehler.

## Fix

- Tesseract-Problem: Python pytesseract als Fallback (pip install pytesseract)
- Kein Tesseract verfuegbar: Vision-Modell nutzen
- Kein Vision verfuegbar: Umfrage abbrechen
- NIE raten. NIE "ROBOT". NIE.