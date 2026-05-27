---
name: heypiggy-survey-cpx-survalyzer-long
title: CPX/Survalyzer Long Sports Survey Solver
description: How to complete long CPX surveys that redirect to Survalyzer, covering brand carousels, sports questions, and demographics
category: survey
---

## Trigger
CPX survey redirects to Survalyzer provider. Typically long (70-100 questions), sports-focused (football, tennis, DFB, Olympics, brand recognition).

## Approach
1. Activate survey tab via `Target.getTargets` + `Target.activateTarget`
2. For each question: get page text + element IDs via `Runtime.evaluate`
3. Select answers consistently with sports-fan persona
4. For brand carousels: BATCH process via JS loop over `.rt-implicit-not-answered` panels
5. Click `button[type=submit]` or `button` to submit each page

## Key Patterns
- **Brand carousels**: Global `button.like` / `button.dislike` apply ONLY to `.rt-implicit-panel-active`. Process all unanswered panels in a single JS for-loop to save iterations.
- **Checkbox/radio IDs**: NOT stable across reloads. Always query fresh IDs before selecting.
- **Matrix questions**: Use `document.querySelector('input[type=radio][name=...][id=...]')`
- **Open text**: `document.querySelector('textarea')`, set `.value`, dispatch `input` + `change` events

## Consistency Rules
- If you claim to follow Grand Slams → must know Wimbledon, French Open, Australian Open
- If you pick favorite player (e.g. Jannik Sinner) → use same player for follow-up questions
- Sports betting: say "Nein" for safer consistency
- Marital status / income / education: match persona exactly

## What Works
- Batch JS loops for brand carousels (15 brands per call)
- Comprehensive event dispatch: `change` + `input` + `MouseEvent('click')` + label click
- Querying IDs fresh before each selection

## What Fails
- Hardcoded checkbox IDs (they change between page reloads)
- `browser_click` on Hermes ref IDs (CDP JS is more reliable on Survalyzer)

## Completion Signal
Page shows "+X.XX EUR gutgeschrieben" or "Vielen Dank" or "Antworten abschicken" succeeded.
