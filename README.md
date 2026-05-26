# SIN-Hermes-Bundle

**Hermes-native Survey Automation Configuration.**

Fireworks-AI-Setup, 412-Retry-Fix, und Hermes-Skills für vollautonome HeyPiggy-Umfragen.

Keine CLI-Tools. Keine Wrapper. Nur `browser_snapshot` + `browser_click` + `browser_cdp`.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/SIN-CLIs/SIN-Hermes-Bundle/main/install.sh | bash
hermes auth add custom:fireworks --type api-key --api-key "$FIREWORKS_AI_API_KEY"
hermes chat -q "Öffne heypiggy.com, starte Umfrage, beantworte alle Fragen."
```

## Inhalt

| Komponente | Zweck |
|-----------|-------|
| `config/fireworks.yaml` | Hermes Config für sinator.delqhi.com Proxy |
| `patches/error_classifier_412.patch` | 412-Retry-Fix für Hermes error_classifier.py |
| `skills/` | 5 Hermes Agent Skills |
| `docs/` | SOP, 412-Fix-Doku, Survey-Run-Guide |

## Struktur

```
├── config/
│   └── fireworks.yaml          # Hermes config.yaml für Fireworks
├── patches/
│   └── error_classifier_412.patch  # 412 + "suspended" → retryable
├── skills/
│   ├── survey-tab-switch/      # Tab-Wechsel bei Provider-Redirect
│   ├── survey-weiter-button/   # Weiter-Button erkennen
│   ├── survey-cdp-workaround/  # CDP-Grundbefehle
│   ├── post-survey/            # Auto-Learning nach Umfrage
│   └── heypiggy-survey-keyingress-cdp/  # keyingress.de Tab-Trick
├── docs/
│   ├── survey-run.md           # Korrekter Survey-Prompt
│   └── 412-retry-fix.md        # Warum und wie der Fix funktioniert
├── install.sh                  # One-Command-Installer
└── README.md                   # Diese Datei
```

## Warum kein SIN-Survey-Bundle?

[SIN-Survey-Bundle](https://github.com/SIN-CLIs/SIN-Survey-Bundle) enthält CLI-Tool-Wrappers (batch_survey.py, cdp-cli) die Hermes **langsamer** machen.

**Fakten:**
| Ansatz | Calls/Seite | 502-Rate | Ergebnis |
|--------|------------|----------|----------|
| CLI-Tools | 10-15 | Sehr hoch | 3 Fragen in 9 Min |
| **Browser nativ** | 2-3 | Niedrig | **8 Fragen in 5 Min** |

Hermes' `browser_snapshot` + `browser_click` sind perfekt optimiert.
0.3s/Call, kein JSON-Parsing, kein JS-Debugging.

→ **SIN-Hermes-Bundle** = Hermes-native Config.
→ **SIN-Survey-Bundle** = CLI-Tools (deprecated, nur für Eigeninitiative).

## Erfolge

- **Survey #1:** 11 Fragen + Slider-CAPTCHA (GfK/NIQ) — Screenout wegen Quota
- **Survey #2:** 8 Fragen (keyingress.de) — **0.20 EUR verdient**, Guthaben 0.28 EUR
- **Skill erstellt:** `heypiggy-survey-keyingress-cdp` — Hermes lernte Tab-Wechsel selbst
- **412-Retry-Fix:** sinator-Proxy mit mehreren internen Keys funktioniert jetzt
