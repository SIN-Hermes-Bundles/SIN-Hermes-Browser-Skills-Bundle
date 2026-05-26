# Survey-Run mit Hermes

## Korrekter Prompt

```bash
hermes chat -q "Öffne https://www.heypiggy.com, finde erste verfügbare Umfrage, starte sie. Beantworte alle Fragen mit browser_snapshot und browser_click. CAPTCHA: browser_console JS-Drag (dispatchEvent). browser_vision nur für CAPTCHA. NIE terminal/CLI-Tools nutzen. NIE Tabs schließen. NIE aufgeben. Stoppe bei 'Vielen Dank'." --max-turns 200
```

## Warum kein CLI

Hermes' native Browser-Tools sind 4-5x schneller als CLI-Wrappers:

| Layer | Zeit |
|-------|------|
| `browser_snapshot` | 0.3s (eine CDP-Runde) |
| `browser_click` | 0.3s (eine CDP-Runde) |
| CLI-Tools | 1.5-3s (terminal→python3→CDP→JSON→zurück) |

CLI-Tools zwingen Hermes dazu:
1. JS-Code zu schreiben
2. JSON-Output zu parsen
3. Bei Fehlern zu debuggen
4. Mehr API-Calls zu machen (= mehr 502-Risiko)

## CAPTCHA

Slider-CAPTCHA per `browser_console`:
```js
document.querySelector('.slider').dispatchEvent(
  new MouseEvent('mousedown', {clientX: sx, clientY: sy, bubbles: true})
)
// ... mousemove ...
document.querySelector('.slider').dispatchEvent(
  new MouseEvent('mouseup', {clientX: tx, clientY: ty, bubbles: true})
)
```

## Tab-Wechsel

Wenn Survey in anderem Tab lädt (z.B. keyingress.de):
- `browser_cdp` → `Target.getTargets` → fremden Tab finden
- `Runtime.evaluate` mit `target_id` → JS auf fremden Tab ausführen
- NIE `browser_navigate` zur Umfrage-URL (zerstört Session)

## Persona-Konsistenz

Hermes speichert automatisch Memories nach jeder Umfrage:
- Haushaltseinkommen
- Wohnort / PLZ
- Familienstand / Kinder
- KI-Haltung

Diese Memories werden bei zukünftigen Umfragen automatisch berücksichtigt.

## Fehlerbehebung

| Problem | Lösung |
|---------|--------|
| 502 Bad Gateway | Warten, Retry kommt automatisch (3x) |
| 412 Suspended | Patch aus `docs/412-retry-fix.md` anwenden |
| Vision-Timeout | `browser_vision` hat 120s timeout in config |
| Tab verschwunden | `browser_cdp` → `Target.getTargets` |
