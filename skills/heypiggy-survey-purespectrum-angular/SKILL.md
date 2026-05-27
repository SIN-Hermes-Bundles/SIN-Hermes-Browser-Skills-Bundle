---
name: heypiggy-survey-purespectrum-angular
description: Solving PureSpectrum surveys with Angular custom elements via CDP
trigger: PureSpectrum, screener.purespectrum.com, ps-select-dropdown, ps-date-question
---

# PureSpectrum Angular Survey Solver

## Problem
PureSpectrum uses Angular with custom elements (`ps-select-dropdown`, `ps-date-question`, `ps-root`). Standard `label.click()` does NOT always register with Angular's form model.

## Solution
Use direct HTML input manipulation:

### Radio Buttons / Checkboxes
```js
const input = document.querySelector(`input[name="ans{QID}.0.{row}"][value="{val}"]`);
input.checked = true;
input.dispatchEvent(new Event('change', {bubbles: true}));
```

Naming pattern: `ans{QID}.0.{row_index}` where row_index = 0,1,2...
Value mapping: 0 = first option, 1 = second, 2 = third

### Custom Dropdowns (ps-select-dropdown)
```js
const dd = document.querySelectorAll('ps-select-dropdown')[index];
const buttons = dd.querySelectorAll('button');
buttons[N].click(); // N = option index (0 = placeholder)
```

### Matrix/Grid Questions
- Page shows only 1 card at a time (e.g., "2/6")
- BUT all radio groups exist in DOM hidden by CSS
- Validation requires ALL rows answered
- Answer all rows at once via JS before submitting

### Text Inputs
```js
const input = document.querySelector('input[type="text"]');
input.value = '...';
input.dispatchEvent(new Event('input', {bubbles: true}));
input.dispatchEvent(new Event('change', {bubbles: true}));
```

## Drag-and-Drop (Angular CDK)

PureSpectrum Attention Checks verwenden Angular CDK Drag-and-Drop.
Siehe `survey-drag-captcha-solver` Skill für die vollständige Lösung.

**Schnellreferenz:**
1. Koordinaten via `getBoundingClientRect()` finden
2. `Input.dispatchMouseEvent` (mouseMoved → mousePressed → mouseMoved* → mouseReleased)
3. ALLE mit `target_id` Parameter
4. JS dispatchEvent (MouseEvents, CDK-Events) wird IGNORIERT

**Trigger-Erkennung:** "Bitte legen Sie die Zahl X in das leere Kästchen"

## Flow
1. InnovateMR security check → red herring → "Auf los geht's los"
2. Redirects to PureSpectrum screener.purespectrum.com
3. Answer date/PLZ/device profiler questions
4. Main survey loads (progress bar resets to 2%)
5. Continue answering until completion or screenout

## Known Patterns
- Attention checks: "Wählen Sie Blau" → select "Blau"
- Device ownership grids: use direct radio manipulation for all rows
- Spending questions: select "Ich habe für keines davon Geld ausgegeben" if low engagement claimed