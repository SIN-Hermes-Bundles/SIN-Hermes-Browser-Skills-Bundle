---
name: survey-drag-captcha-solver
description: Angular CDK Drag-Drop CAPTCHA solving via CDP Input.dispatchMouseEvent - based on Hermes' own successful pattern
title: Survey Drag CAPTCHA Solver
version: 1.0
---

## Trigger
- CAPTCHA zeigt "Ziehen Sie X in das leere Kästchen"
- Angular CDK Drag-Drop (cdk-drag, cdk-drop-list)
- Button bleibt disabled nach einfachem click()

## Erfolgreiches Pattern (von Hermes selbst entdeckt)

### Schritt 1: Elemente finden via CDP

```js
const dragEl = document.querySelector('.cdk-drag, [draggable], [class*=drag]');
const dropEl = document.querySelector('.cdk-drop-list, [class*=drop], [class*=target]');
JSON.stringify({
  drag: dragEl ? {x: dragEl.getBoundingClientRect().x, y: dragEl.getBoundingClientRect().y} : null,
  drop: dropEl ? {x: dropEl.getBoundingClientRect().x, y: dropEl.getBoundingClientRect().y} : null
});
```

### Schritt 2: CDP Mouse Events (HERMES' ERFOLGREICHE METHODE)

**NIE `element.click()` oder `dispatchEvent` nutzen — funktioniert NICHT bei Angular CDK.**

**RICHTIG:** `Input.dispatchMouseEvent` mit echten Koordinaten:

```json
// 1. Mousedown auf drag element
{"type": "mousePressed", "x": DRAG_X, "y": DRAG_Y, "button": "left", "clickCount": 1}

// 2. Mousemove mit Zwischenschritten (mindestens 5)
{"type": "mouseMoved", "x": STEP1_X, "y": STEP1_Y}
{"type": "mouseMoved", "x": STEP2_X, "y": STEP2_Y}
{"type": "mouseMoved", "x": STEP3_X, "y": STEP3_Y}
{"type": "mouseMoved", "x": STEP4_X, "y": STEP4_Y}
{"type": "mouseMoved", "x": DROP_X, "y": DROP_Y}

// 3. Mouseup auf drop target
{"type": "mouseReleased", "x": DROP_X, "y": DROP_Y, "button": "left", "clickCount": 1}
```

### Schritt 3: Verifizieren

```js
const dropZone = document.querySelector('.cdk-drop-list');
JSON.stringify({
  children: dropZone ? dropZone.children.length : 0,
  buttonEnabled: !document.querySelector('[class*=next], #btn_send_ahead')?.disabled
});
```

## Warum CDP funktioniert (und JS nicht)

| Methode | Problem | CDP Lösung |
|---------|---------|------------|
| `el.click()` | Angular ignoriert synthetic clicks | OS-level Mouse Events |
| `dispatchEvent` | CDK prüft `isTrusted=false` | CDP Events sind trusted |
| `Input.dispatchMouseEvent` | ✅ **Echte Pointer Events** | CDK akzeptiert diese |

## Kompletter Flow

```
1. browser_cdp: Runtime.evaluate → Koordinaten finden
2. browser_cdp: Input.dispatchMouseEvent → mousedown
3. browser_cdp: Input.dispatchMouseEvent → 5x mousemove
4. browser_cdp: Input.dispatchMouseEvent → mouseup
5. browser_cdp: Runtime.evaluate → button enabled?
6. browser_click → "Nächste"
```

## Verboten
- ❌ `solve_captcha.py drag` (funktioniert nicht bei CDK)
- ❌ `browser_vision` (sinnlos, kein Text)
- ❌ `dispatchEvent(new DragEvent(...))` (Angular ignoriert synthetic)

## Details
- **5+ Zwischenschritte** — CDK erwartet echten Drag-Pfad
- **Center-Koordinaten**: `rect.left + width/2`, `rect.top + height/2`
- **Button disabled** bis CDK `dropped` Event feuert

## Was funktioniert
- Angular CDK Drag-Drop
- HTML5 Drag & Drop API
- JQuery UI Draggable

## Was NICHT funktioniert
- Canvas-basierte Drag
- reCAPTCHA v2/v3
