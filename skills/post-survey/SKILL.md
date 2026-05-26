---
name: post-survey
description: NACH jeder Umfrage: erstelle Skill mit dem was du gelernt hast
version: 1.0.0
metadata:
  hermes:
    tags: [survey, learning]
    category: survey
---

# Post-Survey Learning

## PFLICHT nach JEDER Umfrage (completed oder screenout):
1. Nutze `skill_manage action=create` mit name="heypiggy-THEMA"
2. Speichere:
   - Provider-Name (CPX, PureSpectrum, Cint, GfK, etc.)
   - Welche Tools haben funktioniert (browser_click, browser_cdp, etc.)
   - Welche Probleme gab es (Tab-Wechsel, Weiter-Button, CAPTCHA)
   - Wie wurden sie geloest (Workaround)
3. Nutze `memory` um Antworten zu speichern:
   - memory add "survey-PROVIDER-weiter" = "input[type=submit] via CDP"
   - memory add "survey-PROVIDER-tab" = "Target.activateTarget"
4. Dann: naechste Umfrage starten
