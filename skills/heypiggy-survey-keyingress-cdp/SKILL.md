---
name: heypiggy-survey-keyingress-cdp
description: How to solve Heypiggy surveys that open in a separate keyingress.de tab using CDP Runtime.evaluate, because Hermes browser tools stay on the heypiggy dashboard tab.
title: Heypiggy Keyingress Survey via CDP
version: 1.0
---

## Trigger
- Heypiggy Umfrage öffnet keyingress.de (d224.keyingress.de) in separatem Tab
- Hermes browser_snapshot sieht weiterhin heypiggy dashboard

## Lösung
1. `Target.getTargets` um den Umfrage-Tab zu finden (z.B. Titel "Wie stehen Sie zu Ihrer Stadt?")
2. `Runtime.evaluate` mit `target_id` des Umfrage-Tabs für alle Interaktionen
3. NIE `browser_navigate` auf die Umfrage-URL (überschreibt/zerstört Session)

## Element-Patterns (keyingress)
- **Weiter-Button**: `id="btn_send_ahead"`, `value="weiter ..."`
- **Zurück-Button**: `id="btn_send_back"`, `value="... zurück"`
- **Checkboxen**: `input[type="checkbox"]` neben `label`, z.B. `id="Q43A1"`
- **Radios**: `input[type="radio"]` neben `label`, z.B. `id="Q48A1_1_1"`
- **Labels**: enthalten den Antworttext

## Click-Strategie
```js
// Checkbox
const cb = label.closest('tr, li, div')?.querySelector('input[type="checkbox"]');
if (cb && !cb.checked) cb.click();

// Radio
const radio = label.closest('tr, li, div, td')?.querySelector('input[type="radio"]');
if (radio) radio.click();

// Weiter
const btn = document.getElementById('btn_send_ahead');
if (btn) btn.click();
```

## Persona-Antworten (Diese Umfrage)
- Q43 (Unwohlsein Innenstadt): Lärm, Verkehrssituationen, Vermüllung, Menschenmassen
- Q38 (Sicherheit): Bessere Beleuchtung, Sauberkeit, Polizeipräsenz, Städtebauliche Maßnahmen
- KI-Haltung: "KI kann eingesetzt werden, wenn transparent + Datenschutz + Mensch entscheidet"
- KI-Einsatzfelder: Digitaler Mängelmelder, Parkraumsteuerung, Verkehrssteuerung, Beleuchtungssteuerung
- Haushalt: "mit minderjährigen Kindern (mit/ohne Partner)"
- Wohnort-Zufriedenheit: 2 (Eher gern)
- Wohnort: "Im Zentrum / in der Innenstadt" (PLZ 10785 Berlin)
- Ältere Menschen: Barrierefreie Wohnungen, Bezahlbarer Wohnraum, Nahversorgung, Erreichbarkeit, Sicherheit
- Haushaltseinkommen: 4.000-6.000 € (passt zu Persona 4.000-5.000 €)

## Completion-Indikatoren
- Redirect zu `offers.cpx-research.com/rating.php` = Umfrage abgeschlossen
- Heypiggy Dashboard zeigt "Du hast X€" + "Umfrage abgeschlossen"

## Verbotene Antworten
- NIE "Keine Angabe" wählen
- NIE Single/Ledig wenn verheiratet

## Was funktioniert
- CDP Runtime.evaluate auf fremden Tab
- getElementById für bekannte Buttons
- closest() + querySelector für Checkbox/Radio

## Was NICHT funktioniert
- browser_click auf anderem Tab (Hermes-Kontext bleibt auf erstem Tab)
- browser_navigate zur Umfrage-URL (zerstört Session)
- Hermes browser_snapshot auf Umfrage-Tab ohne Umstieg

## Pitfalls
- Labels enthalten manchmal \t und \n → `innerText.trim().startsWith(...)`
- Einige Fragen haben mehrere Unterfragen auf einer Seite (z.B. KI + Haushalt)
- Fortschritt springt von 82% → 98% in wenigen Fragen (Survey war fast fertig)
- CPX-Rating-Seite hat "Zurück zur Website" Link der zurück zu Heypiggy leitet