---
name: hermes-survey-bundles
title: Hermes Survey Bundle Architecture — Provider vs Skills Separation
description: "How to organize Hermes-native survey tooling into modular bundles. Provider config (auth, patches, base URLs) separated from application logic (skills, SOPs) so they evolve independently."
version: 1.0.0
metadata:
  hermes:
    tags: [hermes, survey, bundle, architecture, provider, skills]
    category: survey
---

# Hermes Survey Bundle Architecture

## Prinzip

**Provider-Config und Skills MÜSSEN in getrennten Repos leben.**

| Bundle | Inhalt | Update-Frequenz |
|--------|--------|-----------------|
| **Provider-Bundle** | Config, Patches, Auth | Selten (nur bei Provider-Änderungen) |
| **Skills-Bundle** | Skills, SOPs, Docs | Oft (nach jeder Umfrage neuer Skill) |

### Warum getrennt?
- Skills wachsen täglich → willst nicht Provider-Config bei jedem Push berühren
- Provider-Patches (z.B. `error_classifier_412.patch`) sind stabil → sollten nicht in einem Repo mit 50+ Skill-Commits untergehen
- User kann Provider einmalig installieren und Skills später nachladen

## Aktuelle Bundles (SIN-CLIs Ecosystem)

| Repo | URL | Zweck |
|------|-----|-------|
| `SIN-Hermes-Provider-Bundle` | https://github.com/SIN-CLIs/SIN-Hermes-Provider-Bundle | `config/fireworks.yaml`, `patches/error_classifier_412.patch` |
| `SIN-Hermes-Browser-Skills-Bundle` | https://github.com/SIN-CLIs/SIN-Hermes-Browser-Skills-Bundle | 13+ Skills, `docs/survey-run.md` |
| `SIN-Survey-Bundle` | https://github.com/SIN-CLIs/SIN-Survey-Bundle | **DEPRECATED** — CLI-Tools (nur für Eigeninitiative) |

### DEPRECATED: CLI-Tools

Laut Live-Run-Benchmark (AGENTS.md §26):

| Ansatz | Calls/Seite | 502-Rate | Ergebnis |
|--------|------------|----------|----------|
| CLI-Tools | 10-15 | Sehr hoch | 3 Fragen in 9 Min |
| **Browser nativ** | 2-3 | Niedrig | **8 Fragen in 5 Min** |

→ CLI-Tools sind **DEPRECATED**. Nicht löschen, aber niemals als Primary erzwingen.
→ Korrekter Prompt: `browser_snapshot` + `browser_click` + `browser_vision` (nur CAPTCHA).

## Repo-Split Workflow

Wenn ein Bundle gemischte Inhalte hat:

```bash
# 1. Local umbenennen
mv SIN-Hermes-Bundle SIN-Hermes-Browser-Skills-Bundle

# 2. Provider-Files aus Skills-Bundle entfernen
git rm -r config/ patches/ docs/412-retry-fix.md

# 3. Neue Files schreiben (install.sh, README mit Cross-Reference)
# ...

git add -A && git commit -m "refactor: split provider config into separate bundle"

# 4. Altes Repo auf GitHub umbenennen
cd SIN-Hermes-Browser-Skills-Bundle
gh repo rename SIN-Hermes-Browser-Skills-Bundle --repo SIN-CLIs/SIN-Hermes-Bundle -y
git remote set-url origin https://github.com/SIN-CLIs/SIN-Hermes-Browser-Skills-Bundle.git
git push origin main --force

# 5. Neues Provider-Bundle anlegen
git init SIN-Hermes-Provider-Bundle

# 6. Files aus git history des alten Repos extrahieren
git show <commit>:config/fireworks.yaml > config/fireworks.yaml
git show <commit>:patches/error_classifier_412.patch > patches/error_classifier_412.patch
git show <commit>:docs/412-retry-fix.md > docs/412-retry-fix.md

git add -A && git commit -m "feat: initial SIN-Hermes-Provider-Bundle"

# 7. Neues Repo auf GitHub pushen
cd SIN-Hermes-Provider-Bundle
gh repo create SIN-CLIs/SIN-Hermes-Provider-Bundle --public --source=. --remote=origin --push
```

## Install-Skripte

### Provider-Bundle (einmalig)

```bash
curl -fsSL https://raw.githubusercontent.com/SIN-CLIs/SIN-Hermes-Provider-Bundle/main/install.sh | bash
```

Tut:
- `config/fireworks.yaml` → `~/.hermes/config.yaml`
- `patches/error_classifier_412.patch` anwenden
- `max_turns=999999` setzen

### Skills-Bundle (oft)

```bash
curl -fsSL https://raw.githubusercontent.com/SIN-CLIs/SIN-Hermes-Browser-Skills-Bundle/main/install.sh | bash
```

Tut:
- Alle Skills aus `skills/` → `~/.hermes/skills/survey/`

## README-Cross-References

Jedes Bundle-README MUSS auf das andere Bundle verlinken:

```markdown
Für Provider-Konfig siehe [SIN-Hermes-Provider-Bundle](...).
Für Browser-Skills siehe [SIN-Hermes-Browser-Skills-Bundle](...).
```

## Pitfalls

- **NIE `git filter-repo` nutzen** für einfachen Split — Overkill, Rewrite-History
- **Immer Cross-References in READMEs** — sonst findet User das andere Bundle nicht
- **Altes Repo auf GitHub umbenennen, nicht löschen** — verhindert Broken Links
- **`install.sh` im Skills-Bundle darf keinen Provider-Config kopieren** — sonst ist die Trennung wertlos