---
name: survey-drag-captcha-solver
title: Angular CDK Drag-Drop CAPTCHA solving via CDP Input.dispatchMouseEvent
description: Loest Angular CDK Drag-and-Drop (PureSpectrum Attention Checks) in ~2s via CDP Input.dispatchMouseEvent mit target_id.
version: 2.0.0
metadata:
  hermes:
    tags: [survey, captcha, drag-and-drop, angular, cdk, purespectrum]
    category: survey
---

# Angular CDK Drag-and-Drop Solver

## Wichtigste Erkenntnis
**browser_cdp Input.dispatchMouseEvent funktioniert NUR mit target_id Parameter!**
Ohne target_id: error "-32601: Input.dispatchMouseEvent wasn't found"
Mit target_id: funktioniert perfekt!

## Speed: ~2s (5 CDP Calls)

## Flow

### Step 1: Koordinaten finden
```javascript
// CDP Runtime.evaluate mit target_id
const items = document.querySelectorAll('.cdk-drag img');
items.forEach((img, i) => {
  const rect = img.getBoundingClientRect();
  // alt text = Zahl, x/y = center
});
const drop = document.getElementById('dropZoneList');
const dropRect = drop.getBoundingClientRect();
```

### Step 2: Drag ausführen (5 CDP Calls)
```
Input.dispatchMouseEvent {type: "mouseMoved", x: srcX, y: srcY}
Input.dispatchMouseEvent {type: "mousePressed", button: "left", buttons: 1, x: srcX, y: srcY}
Input.dispatchMouseEvent {type: "mouseMoved", button: "left", buttons: 1, x: srcX, y: midY}
Input.dispatchMouseEvent {type: "mouseMoved", button: "left", buttons: 1, x: tgtX, y: tgtY}
Input.dispatchMouseEvent {type: "mouseReleased", button: "left", buttons: 0, x: tgtX, y: tgtY}
```
ALLE mit target_id!

### Step 3: Prüfen
Nach Drag: "Remove dragged item" button erscheint = Erfolg!

## PureSpectrum Specifics
- Drag-Items: `.cdk-drag img` mit alt="##" (die Nummer)
- Drop-Zone: `#dropZoneList`
- Quell-Liste: `.cdk-drop-list:not(#dropZoneList)`
- Button: `ps-next-button button` (text: "Nächste")

## Was NICHT funktioniert
- JavaScript dispatchEvent (MouseEvents) werden von CDK ignoriert
- DOM-Manipulation (appendChild) ohne CDP Drag
- CDK CustomEvents (cdkDropListDropped) ohne echte Mausbewegung

## Trigger
- "Bitte legen Sie die Zahl X in das leere Kästchen"
- ps-drag-and-drop-question im DOM
- cdk-drag Elemente sichtbar

## Pitfalls
- NIEMALS ohne target_id versuchen
- NIEMALS JS-Events dispatch (wird ignoriert)
- Koordinaten sind relativ zum Viewport (getBoundingClientRect)
- Nach Reset: Element zurück in Quell-Liste verschieben
