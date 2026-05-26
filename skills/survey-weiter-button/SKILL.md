---
name: survey-weiter-button
description: Wenn browser_click den Weiter-Button nicht klicken kann, CDP JS-Click oder input[type=submit] nutzen
version: 1.0.0
metadata:
  hermes:
    tags: [survey, click, cdp]
    category: survey
---

# Weiter-Button Workaround

## Problem
Viele Umfragen haben Weiter-Button als input[type=submit] oder
custom-styled div/span. browser_click findet sie nicht oder klickt
den falschen Button (z.B. "X" Schliessen).

## Loesung
1. DOM per `browser_cdp` Runtime.evaluate analysieren:
   `document.querySelector('input[type=submit]')`
2. Wenn gefunden: per JS klicken:
   `document.querySelector('input[type=submit]').click()`
3. Wenn nicht: nach Button mit Text "Weiter" suchen:
   `Array.from(document.querySelectorAll('button, a, [role=button], input[type=submit], div, span')).find(el => el.textContent?.includes('Weiter'))?.click()`
4. Wenn auch nicht: Formular submit() aufrufen:
   `document.querySelector('form')?.submit()`
5. Nach Klick: warten und Snapshot machen

## Vorsicht
- `browser_click @eX` klickt OFT den falschen Button (z.B. X-Schliessen)
- IMMER zuerst per JS kontrollieren WELCHES Element angeklickt wird
- input[type=submit] wird von browser_click NICHT als Button erkannt
