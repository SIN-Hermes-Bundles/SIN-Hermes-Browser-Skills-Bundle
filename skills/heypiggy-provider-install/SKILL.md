---
description: Installiert das SIN-Hermes-Provider-Bundle auf einem neuen Mac. Setzt Hermes Config, Pool-Router, 412-Patch, UA-Spoof, und Fireworks Auth auf. Einmalig pro Maschine.
trigger:
  - installiere provider bundle
  - provider installieren
  - installiere fireworks provider
  - setup hermes provider
  - neuer mac setup
  - installiere pool router
  - hermes auth fireworks
  - setup sin-hermes provider
  - provider bundle neu installieren
  - router installieren
  - 412 patch installieren
  - ua spoof installieren
---

# heypiggy-provider-install

Installiert das [SIN-Hermes-Provider-Bundle](https://github.com/SIN-Hermes-Bundles/SIN-Hermes-Provider-Bundle) auf einem neuen Mac. Das Bundle enthält:

- Pool-Router (localhost:9998) mit Auto-Failover über sinatorpool1/2/3
- 412 PRECONDITION_FAILED Retry-Patch
- User-Agent Spoof-Patch
- Hermes Config mit `max_turns=999999`
- Auto-start via launchd (Login + Crash-Restart)

## Preconditions

- `FIREWORKS_AI_API_KEY` muss als Umgebungsvariable gesetzt sein
- Hermes Agent muss installiert sein (`.hermes/` existiert)

## Steps

### 1. API-Key prüfen

```bash
echo "FIREWORKS_AI_API_KEY ist ${FIREWORKS_AI_API_KEY:-NICHT GESETZT}"
```

Wenn nicht gesetzt: Benutzer nach Key fragen oder abbrechen.

### 2. Installer herunterladen und ausführen

```bash
curl -fsSL https://raw.githubusercontent.com/SIN-Hermes-Bundles/SIN-Hermes-Provider-Bundle/main/install.sh | bash
```

### 3. Auth einrichten

```bash
hermes auth add custom:fireworks --type api-key --api-key "$FIREWORKS_AI_API_KEY"
```

### 4. Verifizierung

```bash
echo "=== Verifizierung ===" && \
pgrep -f pool-router.py && echo "[OK] Router läuft" || echo "[FAIL] Router nicht läuft" && \
launchctl list | grep -q sinhermes && echo "[OK] launchd geladen" || echo "[FAIL] launchd nicht geladen" && \
grep -q "base_url.*localhost:9998" ~/.hermes/config.yaml && echo "[OK] Config auf localhost:9998" || echo "[FAIL] Config falsch" && \
grep -q "status_code == 412" ~/.hermes/hermes-agent/agent/error_classifier.py && echo "[OK] 412 Patch" || echo "[FAIL] 412 Patch fehlt" && \
ls ~/.hermes/hermes-agent/_ua_patch.py >/dev/null 2>&1 && echo "[OK] UA-Spoof" || echo "[FAIL] UA-Spoof fehlt" && \
grep -q "max_turns: 999999" ~/.hermes/config.yaml && echo "[OK] Unlimited max_turns" || echo "[FAIL] max_turns nicht gesetzt"
```

Alle 6 Checks müssen `[OK]` sein.

### 5. Test-Request (optional)

```bash
curl -s http://localhost:9998/v1/models 2>&1 | head -5 || echo "Router nicht erreichbar (normal wenn noch kein Auth)"
```

## Troubleshooting

| Fehler | Lösung |
|--------|--------|
| "Patch may already be applied" | Ignorieren — Patch war schon drauf |
| Router startet nicht | `launchctl load ~/Library/LaunchAgents/com.sinhermes.poolrouter.plist` |
| 412 Patch fehlt | `docs/412-retry-fix.md` im Bundle für manuelle Anleitung |
| UA-Spoof fehlt | `docs/ua-spoof.md` im Bundle für manuelle Anleitung |

## Links

- [SIN-Hermes-Provider-Bundle](https://github.com/SIN-Hermes-Bundles/SIN-Hermes-Provider-Bundle)
- [SIN-Hermes-Complete (Meta-Installer)](https://github.com/SIN-Hermes-Bundles/SIN-Hermes-Complete)
