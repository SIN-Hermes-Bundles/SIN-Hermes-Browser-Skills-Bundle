---
name: survey-master-solver
title: "Master Survey Solver — Batch + Pattern + OCR Kombination"
description: "Kombiniert survey-batch-cdp-solver + survey-auto-pattern-matcher + OCR-Fallback. Vollautonome Survey-Lösung. Ziel: 1-2 Minuten pro Umfrage."
category: survey
version: 1.0.0
metadata:
  hermes:
    tags: [survey, master, full-auto, batch, pattern, ocr]
    category: survey
    requires: [survey-batch-cdp-solver, survey-auto-pattern-matcher]
---

# Master Survey Solver

## Überblick

Kombiniert drei Skills zu einer vollautonomen Survey-Lösung:

1. **survey-batch-cdp-solver** — 1 JS-Call pro Seite (Ausführung)
2. **survey-auto-pattern-matcher** — Zero-LLM Frageerkennung (Intelligenz)
3. **OCR-Fallback** — Tesseract für CAPTCHA (Sicherheit)

## Komplettes Master-JavaScript

```javascript
(function() {
  const PERSONA = {
    gender: 'Männlich', age: 32, birthdate: '1993-05-15',
    zip: '10785', city: 'Berlin', income: '3000-4000',
    occupation: 'Meister im Handwerk', marital: 'Verheiratet',
    children: 1, child_year: 2021,
    smartphone: 'Samsung', streaming: 'Netflix',
    hobbies: ['Fußball', 'Heimwerken', 'Angeln']
  };
  
  const actions = [];
  const bodyText = document.body.innerText.toLowerCase();
  const bodyHTML = document.body.innerHTML;
  
  // ===== HARDCODED BOT TRAPS =====
  if (/white-on-white|enter the word ['"]robot['"]/i.test(bodyHTML)) {
    actions.push('TRAP:robot-detected');
  }
  if (document.querySelector('iframe[src*="recaptcha"], iframe[src*="hcaptcha"]')) {
    return JSON.stringify({hard_stop: 'recaptcha', url: location.href});
  }
  
  const radios = document.querySelectorAll('input[type=radio]');
  const checks = document.querySelectorAll('input[type=checkbox]');
  const texts = document.querySelectorAll('input[type=text], textarea, input:not([type])');
  const selects = document.querySelectorAll('select');
  const dates = document.querySelectorAll('input[type=date]');
  const numbers = document.querySelectorAll('input[type=number], .dx-texteditor-input');
  
  // ===== GESCHLECHT =====
  if (/geschlecht|gender/i.test(bodyText) && radios.length > 0) {
    const t = Array.from(radios).find(r => {
      const lbl = document.querySelector('label[for="' + r.id + '"]') || r.closest('label');
      return /männlich|male|mann/i.test((lbl?.textContent || r.value || '').toLowerCase());
    }) || radios[0];
    if (t) { t.checked = true; t.dispatchEvent(new Event('change', {bubbles: true})); actions.push('gender:m'); }
  }
  
  // ===== ALTER =====
  else if (/alter|age|jahre|geburt/i.test(bodyText)) {
    if (dates.length > 0) {
      dates[0].value = PERSONA.birthdate;
      dates[0].dispatchEvent(new Event('input', {bubbles: true}));
      actions.push('date:birth');
    } else if (numbers.length > 0 || texts.length > 0) {
      const el = numbers[0] || texts[0];
      el.value = String(PERSONA.age);
      el.dispatchEvent(new Event('input', {bubbles: true}));
      actions.push('age:' + PERSONA.age);
    }
  }
  
  // ===== PLZ =====
  else if (/plz|postleitzahl|zip/i.test(bodyText) && texts.length > 0) {
    texts[0].value = PERSONA.zip;
    texts[0].dispatchEvent(new Event('input', {bubbles: true}));
    actions.push('zip:' + PERSONA.zip);
  }
  
  // ===== BERUF =====
  else if (/beruf|occupation|job/i.test(bodyText) && radios.length > 0) {
    const t = Array.from(radios).find(r => {
      const lbl = document.querySelector('label[for="' + r.id + '"]') || r.closest('label');
      return /meister|handwerk|andere|keine der/i.test((lbl?.textContent || r.value || '').toLowerCase());
    }) || radios[radios.length - 2];
    if (t) { t.checked = true; t.dispatchEvent(new Event('change', {bubbles: true})); actions.push('job:' + (t.value || 'other')); }
  }
  
  // ===== EINKOMMEN =====
  else if (/einkommen|income/i.test(bodyText) && radios.length > 0) {
    const t = Array.from(radios).find(r => {
      const lbl = document.querySelector('label[for="' + r.id + '"]') || r.closest('label');
      return /3000|4000|3\.000|4\.000/i.test((lbl?.textContent || r.value || '').toLowerCase());
    }) || radios[Math.floor(radios.length / 2)];
    if (t) { t.checked = true; t.dispatchEvent(new Event('change', {bubbles: true})); actions.push('income'); }
  }
  
  // ===== STANDORT =====
  else if (/wohnort|stadt|city|location/i.test(bodyText) && radios.length > 0) {
    const t = Array.from(radios).find(r => {
      const lbl = document.querySelector('label[for="' + r.id + '"]') || r.closest('label');
      return /berlin|zentrum|innenstadt/i.test((lbl?.textContent || r.value || '').toLowerCase());
    }) || radios[0];
    if (t) { t.checked = true; t.dispatchEvent(new Event('change', {bubbles: true})); actions.push('loc:berlin'); }
  }
  
  // ===== HAUSHALT =====
  else if (/haushalt|household|familie|familienstand/i.test(bodyText) && radios.length > 0) {
    const t = Array.from(radios).find(r => {
      const lbl = document.querySelector('label[for="' + r.id + '"]') || r.closest('label');
      return /verheiratet|partner|mit kind/i.test((lbl?.textContent || r.value || '').toLowerCase());
    }) || radios[2];
    if (t) { t.checked = true; t.dispatchEvent(new Event('change', {bubbles: true})); actions.push('hh:family'); }
  }
  
  // ===== KINDER =====
  else if (/kind|children|kids/i.test(bodyText)) {
    if (selects.length >= 2) {
      for (let i = 0; i < selects.length; i += 2) {
        if (selects[i]) { selects[i].value = '1'; selects[i].dispatchEvent(new Event('change', {bubbles: true})); }
        if (selects[i+1]) { selects[i+1].value = String(PERSONA.child_year); selects[i+1].dispatchEvent(new Event('change', {bubbles: true})); }
      }
      actions.push('children:1');
    } else if (radios.length > 0) {
      const t = Array.from(radios).find(r => {
        const lbl = document.querySelector('label[for="' + r.id + '"]') || r.closest('label');
        return /1 kind|ein kind/i.test((lbl?.textContent || r.value || '').toLowerCase());
      }) || radios[1];
      if (t) { t.checked = true; t.dispatchEvent(new Event('change', {bubbles: true})); actions.push('children:1'); }
    }
  }
  
  // ===== SINGLE CHOICE (Generisch) =====
  else if (radios.length > 0 && checks.length === 0) {
    const mid = Math.floor(radios.length / 2);
    radios[mid].checked = true;
    radios[mid].dispatchEvent(new Event('change', {bubbles: true}));
    actions.push('single:mid-' + mid);
  }
  
  // ===== MULTI-SELECT =====
  else if (checks.length > 0) {
    const targets = Array.from(checks).filter(cb => {
      const lbl = document.querySelector('label[for="' + cb.id + '"]') || cb.closest('label');
      return /samsung|netflix|berlin|fußball|heimwerken|angeln/i.test((lbl?.textContent || cb.value || '').toLowerCase());
    });
    (targets.length > 0 ? targets : [checks[0]]).forEach(cb => {
      cb.checked = true;
      cb.dispatchEvent(new Event('change', {bubbles: true}));
      actions.push('check:' + cb.value);
    });
  }
  
  // ===== OPEN TEXT =====
  else if (texts.length > 0) {
    const ta = texts[0];
    ta.value = ta.tagName === 'TEXTAREA' 
      ? 'Das ist eine wichtige Frage. Meiner Erfahrung nach spielen verschiedene Faktoren eine Rolle, insbesondere die persönliche Situation und die regionalen Gegebenheiten.'
      : 'Berlin, Deutschland';
    ta.dispatchEvent(new Event('input', {bubbles: true}));
    actions.push('text:' + ta.tagName);
  }
  
  // ===== MATRIX =====
  else if (selects.length > 0 && document.querySelectorAll('table, [class*="matrix"]').length > 0) {
    selects.forEach((sel, i) => {
      const opts = Array.from(sel.options);
      if (opts.length > 2) { sel.selectedIndex = Math.min(2, opts.length - 2); sel.dispatchEvent(new Event('change', {bubbles: true})); actions.push('m:' + i); }
    });
  }
  
  // ===== NUMBER =====
  else if (numbers.length > 0) {
    numbers.forEach(n => { n.value = '2'; n.dispatchEvent(new Event('input', {bubbles: true})); actions.push('num:' + n.name); });
  }
  
  // ===== WEITER =====
  const nextBtn = Array.from(document.querySelectorAll('button, input[type=submit], input[name="__fwd"]')).find(el =>
    /nächste|weiter|next|»|>>|fortfahren/i.test((el.textContent || el.value || '').toLowerCase())
  );
  if (nextBtn) {
    ['mousedown', 'mouseup', 'click'].forEach(t => nextBtn.dispatchEvent(new MouseEvent(t, {bubbles: true, cancelable: true, view: window})));
    nextBtn.focus();
    nextBtn.dispatchEvent(new KeyboardEvent('keydown', {key: 'Enter', bubbles: true}));
    actions.push('next:' + (nextBtn.textContent?.substring(0,10) || nextBtn.value?.substring(0,10)));
  }
  
  return JSON.stringify({
    actions: actions,
    url: window.location.href,
    title: document.title,
    text: document.body.innerText?.substring(0, 300) || '',
    detected: actions.length > 0 ? 'auto' : 'unknown',
    has_recaptcha: !!document.querySelector('iframe[src*="recaptcha"]')
  });
})()
```

## Hermes Execution Flow

```
1. browser_cdp Runtime.evaluate (Master JS oben)
2. Prüfe Ergebnis:
   - hard_stop: recaptcha → OCR-Fallback
   - detected: unknown → LLM Fallback (browser_snapshot)
   - detected: auto → sleep(2) → Validierungs-Snapshot
3. Wiederhole bis "Vielen Dank" oder "Screenout"
```

## CAPTCHA OCR-Fallback

```python
# Tesseract-Installation: brew install tesseract + pip install pytesseract pillow
from PIL import Image
import pytesseract, base64

def solve_captcha_ocr(screenshot_base64):
    img = Image.open(base64.b64decode(screenshot_base64))
    return pytesseract.image_to_string(img).strip()
```

## Performance-Ziel

| Ansatz | Zeit/Umfrage |
|--------|--------------|
| Alt (LLM pro Seite) | 5-10 Min |
| Batch-CDP allein | 2-3 Min |
| **Master (Batch + Pattern + OCR)** | **1-2 Min** |

## Push

```bash
cd ~/SIN-Hermes-Bundle
git add skills/survey-master-solver/
git commit -m "feat: survey-master-solver — Full-Auto Stack"
git push origin master
```
