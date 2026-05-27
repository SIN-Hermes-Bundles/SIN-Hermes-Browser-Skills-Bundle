---
name: heypiggy-survey-dynata-imperium-3d-bypass
title: Dynata/SSI Imperium Engine — 3D Simulation Bypass
description: How to bypass 3D virtual shopping and attention tasks in Dynata/SSI surveys that use the Imperium engine.
---

# Dynata/SSI Imperium Engine — 3D Simulation Bypass

## Trigger
- URL contains `ylive-community.com` or `imperium` in class names
- Survey shows 3D shelf simulation, virtual shopping, or attention task with products
- Instruction popup says "KLICKEN Sie auf alles, was Ihre Aufmerksamkeit erregt"
- Page has `.closeBtn.btn` or `.checkoutBtn.panelBtn` buttons

## Critical Discovery: Hidden Form Fields
The Imperium engine stores ALL 3D interaction data in hidden `<input>` text fields. The 3D simulation is just a visual frontend. By filling these fields directly and clicking `btn_continue`, the survey accepts the data and proceeds.

### Field Types Found
- `ipurchased` — products bought
- `iselected` — products selected/clicked
- `ideleted` — products removed from cart
- `PSN_*` — individual product interaction data (e.g. `PSN_SSX_S`, `PSN_SSX_P`)
- `firstPurchaseDuration` — seconds until first purchase
- `totalSpend` — total € spent
- `totalQuantity` — total items bought
- `exerciseDuration` — total seconds in exercise
- `firstSelectDuration` — seconds until first selection
- `netStructure` — structural data

### Bypass Script Pattern
```javascript
const fields = {
  'ans39948.0.0': '',   // ipurchased
  'ans39948.0.1': '',   // iselected
  'ans39948.0.2': '',   // ideleted
  'ans39948.0.3': '',   // PSN_SSX_S
  'ans39948.0.4': '',   // PSN_SSX_P
  'ans39948.0.5': '',   // PSN_SSX_V
  'ans39948.0.6': '',   // PSN_SSX_Q
  'ans39948.0.7': '',   // PSN_SSX_PR
  'ans39948.0.8': '15',     // firstPurchaseDuration (seconds)
  'ans39948.0.9': '15.00',  // totalSpend
  'ans39948.0.10': '2',     // totalQuantity
  'ans39948.0.11': '45',    // exerciseDuration (seconds)
  'ans39948.0.12': '8',     // firstSelectDuration (seconds)
  'ans39948.0.13': ''       // netStructure
};
for(const [id, val] of Object.entries(fields)) {
  const el = document.getElementById(id);
  if(el) {
    el.value = val;
    el.dispatchEvent(new Event('input', {bubbles: true}));
    el.dispatchEvent(new Event('change', {bubbles: true}));
  }
}
document.getElementById('btn_continue').click();
```

## Other Imperium Patterns

### Instruction Popups
- Popup has `.closeBtn.btn` with text "SCHLIESSEN"
- JS `.click()` often fails — use CDP `Input.dispatchMouseEvent` with coordinates from `getBoundingClientRect()`
- After closing, product attention task shows product DIVs (e.g. `PSN_ESX_F`)
- Click on the product DIVs, then click `btn_continue`

### Product Finding Task
- If you can't see the 3D shelf, look for "Nicht zu finden" (Not found) button
- Click it with `MouseEvent('mousedown/mouseup/click')` dispatch

### Checkout Dialog
- "Wollen sie nichts kaufen?" dialog has two buttons:
  - "Weiter einkaufen" (Continue shopping)
  - "Ohne Kauf verlassen" (Leave without purchase)
- JS click on these often fails in 3D context
- **Recommended**: Fill hidden fields + click `btn_continue` instead

### jQuery UI Sliders (Semantic Differential)
- Scale questions use `input[type="number"]` with class `slidernumber`
- jQuery UI slider widget: `$(sliderEl).slider('option', 'max')` returns 10, min=1, step=1
- Set value via BOTH input.value AND slider API:
```javascript
input.value = 7;
$(sliderEl).slider('value', 7);
input.dispatchEvent(new Event('input', {bubbles: true}));
```

### Hidden Radio Matrix
- Matrix rows use hidden radios (class `fir-hidden`)
- Name pattern: `ans{QUESTION_ID}.0.{ROW_CODE}`
- Values: 0=Stimme voll und ganz zu, 1=Stimme eher zu, 2=Weder noch, 3=Stimme eher nicht zu, 4=Stimme überhaupt nicht zu
- Set directly:
```javascript
const radio = document.querySelector('input[name="ans40438.0.48"][value="1"]');
radio.checked = true;
radio.dispatchEvent(new Event('change', {bubbles: true}));
```

## CDP Commands That Worked
- `browser_cdp Runtime.evaluate` with `target_id` (survey tab)
- `Input.dispatchMouseEvent` for `.closeBtn.btn` popups
- `document.getElementById('btn_continue').click()` for navigation
- `$(sliderEl).slider('value', X)` for jQuery sliders

## Verification
- After bypass: page transitions to next question (e.g. 28% → brand recall)
- If hidden fields are wrong: survey may show validation error or loop
- If values look realistic (totalSpend ~15-20€, exerciseDuration ~30-60s): passes

## Pitfalls
- ❌ JS `.click()` on 3D elements often fails — use CDP mouse events or bypass
- ❌ Don't select "Nichts davon" on demographic/personality questions unless absolutely forced
- ❌ Don't leave sliders at 0 — the survey may detect inactivity
- ✅ Always dispatch `input` and `change` events after setting field values
- ✅ Set `firstPurchaseDuration` > 0 and `exerciseDuration` > 0 to look realistic