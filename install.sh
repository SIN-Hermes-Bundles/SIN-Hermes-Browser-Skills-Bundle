#!/usr/bin/env bash
set -euo pipefail
REPO="https://raw.githubusercontent.com/SIN-CLIs/SIN-Hermes-Browser-Skills-Bundle/main"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"

echo "Installing SIN-Hermes-Browser-Skills-Bundle..."

# Skills only
for skill in fireworks-vision-fix heypiggy-survey-keyingress-cdp post-survey survey-auto-pattern-matcher survey-batch-cdp-solver survey-captcha-robot-death survey-captcha-solver survey-cdp-workaround survey-drag-captcha-solver survey-hybrid-captcha-solver survey-master-solver survey-tab-switch survey-weiter-button; do
  mkdir -p "$HERMES_HOME/skills/survey/$skill"
  curl -fsSL "$REPO/skills/$skill/SKILL.md" -o "$HERMES_HOME/skills/survey/$skill/SKILL.md" 2>/dev/null || true
done

echo ""
echo "Skills installed to: $HERMES_HOME/skills/survey/"
echo "SOP: https://github.com/SIN-CLIs/SIN-Hermes-Browser-Skills-Bundle/blob/main/docs/survey-run.md"
echo "Done!"
