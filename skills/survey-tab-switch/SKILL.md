---
name: survey-tab-switch
description: Nach Klick auf Umfrage starten wird Survey in NEUEM TAB geoeffnet
version: 1.0.0
metadata:
  hermes:
    tags: [survey, tab, cdp]
    category: survey
---

# Survey Tab-Wechsel

Nach Klick auf "Umfrage starten" auf heypiggy.com: NEUER TAB mit Provider.
browser_snapshot/click bleiben im alten Tab. Loesung:
1. browser_cdp Target.getTargets -> neuen Tab finden
2. browser_cdp Target.activateTarget -> Tab aktivieren
3. Oder: browser_navigate zur Provider-URL
