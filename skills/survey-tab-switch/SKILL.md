---
name: survey-tab-switch
title: Heypiggy Tab Management — Aktivieren, Wechseln, Korrupt-Erkennung
description: Loest Tab-Wechsel-Probleme bei Heypiggy. Target.activateTarget schlaegt fehl, browser_navigate ist der einzige zuverlaessige Weg.
version: 2.0.0
metadata:
  hermes:
    tags: [survey, tabs, heypiggy, browser, cdp]
    category: survey
---

# Heypiggy Survey Tab Management

## KRITISCH: Tab-Wechsel funktioniert NICHT via Target.activateTarget

**browser_snapshot zeigt IMMER den zuletzt mit browser_navigate geoeffneten Tab.**
Target.activateTarget aendert NICHTS am Snapshot — der frame_id bleibt gleich!

## Regel: NUR browser_navigate wechselt den Tab

```
❌ browser_cdp Target.activateTarget  # WIRD IGNORIERT!
✅ browser_navigate(url)              # Wechselt Tab + laedt Seite frisch
```

## Workflow: Umfrage starten

```
1. browser_navigate("https://www.heypiggy.com/?page=dashboard")
2. browser_snapshot → finde Umfrage [ref=e8..e19]
3. browser_click(e8) → Dialog "Umfrage starten" erscheint
4. browser_click(e21) → "Umfrage starten" Button
5. browser_cdp Target.getTargets → neuen Tab finden
6. browser_navigate(survey_url) → zum Survey-Tab wechseln
```

## Nach Survey-Abschluss (Redirect)

Wenn URL `?type=out&amount_user=X.XXXX` erscheint:
```
1. Popup "Schließen" klicken
2. browser_navigate("https://www.heypiggy.com/?page=dashboard")  # FRISCH laden!
3. NIEMALS auf dem "out"-Tab weitermachen — der ist korrupt!
```

## Korrupt-Erkennung

Dashboard-Tab ist KORRUPT wenn:
- Klicks auf [e8..e19] keinen Dialog oeffnen
- URL enthaelt `?type=out`
- frame_id wechselt nicht nach Target.activateTarget

Loesung: browser_navigate zum Dashboard — NICHT Target.activateTarget!

## Tab-Cleanup

NIEMALS Tabs schliessen! (Laut AGENTS.md §0a)
Wenn Tabs ueberfluessig: einfach ignorieren, neue mit browser_navigate oeffnen.
