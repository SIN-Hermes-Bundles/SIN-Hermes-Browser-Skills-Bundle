---
name: survey-cdp-workaround
description: Wenn browser_*/Hermes-Tools nicht funktionieren, CDP direkt nutzen
version: 1.0.0
metadata:
  hermes:
    tags: [survey, cdp, workaround]
    category: survey
---

# CDP Workaround

## Wann
- browser_click klickt falsches Element
- browser_snapshot zeigt falschen Tab
- browser_type funktioniert nicht
- Weiter-Button wird nicht gefunden
- Checkbox-Auswahl wird nicht registriert

## CDP Grundbefehle
1. `browser_cdp` Target.getTargets -> alle Tabs
2. `browser_cdp` Target.activateTarget -> Tab wechseln
3. `browser_cdp` Runtime.evaluate -> JS ausfuehren
4. `browser_cdp` Input.dispatchMouseEvent -> Mausklick (isTrusted=true)
5. `browser_cdp` Input.insertText -> Text eingeben
6. `browser_cdp` Page.navigate -> URL laden

## Checkboxen setzen per JS
```javascript
document.querySelectorAll('input[type=checkbox]').forEach((cb,i)=>{
  if(i<3) cb.checked=true; // erste 3 Checkboxen ankreuzen
});
// Event ausloesen
document.querySelectorAll('input[type=checkbox]').forEach(cb=>{
  cb.dispatchEvent(new Event('change',{bubbles:true}));
  cb.dispatchEvent(new Event('input',{bubbles:true}));
});
```

## Radio waehlen per JS
```javascript
var r = document.querySelector('input[type=radio][value="..."]');
if(r) { r.checked=true; r.dispatchEvent(new Event('change',{bubbles:true})); }
```

## Text eingeben per CDP
```javascript
var el = document.querySelector('input[type=text], textarea');
if(el) { el.value='...'; el.dispatchEvent(new Event('input',{bubbles:true})); }
```
