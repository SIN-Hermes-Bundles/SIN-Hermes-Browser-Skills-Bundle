# SIN-Hermes-Browser-Skills-Bundle

**Hermes Agent Skills für vollautonome HeyPiggy-Umfragen.**

Keine CLI-Tools. Keine Wrapper. Nur `browser_snapshot` + `browser_click` + `browser_cdp`.

Für Provider-Konfig (Fireworks, 412-Fix) siehe [SIN-Hermes-Provider-Bundle](https://github.com/SIN-CLIs/SIN-Hermes-Provider-Bundle).

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/SIN-CLIs/SIN-Hermes-Browser-Skills-Bundle/main/install.sh | bash
```

## Inhalt

| Komponente | Zweck |
|-----------|-------|
| `skills/` | 13 Hermes Agent Skills |
| `docs/` | Survey-Run-Guide |

## Struktur

```
├── skills/
│   ├── fireworks-vision-fix/           # Vision Base-URL Fix
│   ├── heypiggy-survey-keyingress-cdp/ # keyingress.de Tab-Trick
│   ├── post-survey/                    # Auto-Learning nach Umfrage
│   ├── survey-auto-pattern-matcher/    # Zero-LLM Pattern-Matching
│   ├── survey-batch-cdp-solver/        # 1 Call pro Seite
│   ├── survey-captcha-robot-death/     # ROBOT=DEATH Regel
│   ├── survey-captcha-solver/          # Tesseract OCR + Vision
│   ├── survey-cdp-workaround/          # Raw CDP Fallback
│   ├── survey-drag-captcha-solver/     # Angular CDK Drag-Drop
│   ├── survey-hybrid-captcha-solver/   # Tesseract + LLM Vision
│   ├── survey-master-solver/           # Batch + Pattern + OCR Kombi
│   ├── survey-tab-switch/              # Tab-Wechsel bei Redirect
│   └── survey-weiter-button/           # CDP JS-Click Fallback
├── docs/
│   └── survey-run.md                   # Korrekter Survey-Prompt
├── install.sh                          # One-Command-Installer
└── README.md                           # Diese Datei
```

## Erfolge

- **Survey #1:** 11 Fragen + Slider-CAPTCHA (GfK/NIQ) — Screenout wegen Quota
- **Survey #2:** 8 Fragen (keyingress.de) — **0.20 EUR verdient**, Guthaben 0.28 EUR
- **Skill erstellt:** `heypiggy-survey-keyingress-cdp` — Hermes lernte Tab-Wechsel selbst
- **412-Retry-Fix:** In Provider-Bundle (siehe SIN-Hermes-Provider-Bundle)
