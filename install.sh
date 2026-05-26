#!/usr/bin/env bash
set -euo pipefail
REPO="https://raw.githubusercontent.com/SIN-CLIs/SIN-Hermes-Bundle/main"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"

echo "Installing SIN-Hermes-Bundle..."

# 1. Provider Plugin
mkdir -p "$HERMES_HOME/plugins/model-providers/fireworks-ai"
curl -fsSL "$REPO/config/fireworks.yaml" -o "$HERMES_HOME/config.yaml"

# 2. UA Patch
curl -fsSL "$REPO/../SIN-Survey-Bundle/tools/_ua_patch.py" -o "$HERMES_HOME/hermes-agent/_ua_patch.py" 2>/dev/null || true
if ! grep -q "_ua_patch" "$HERMES_HOME/hermes-agent/run_agent.py" 2>/dev/null; then
  sed -i '' 's/import re/import _ua_patch  # noqa\nimport re/' "$HERMES_HOME/hermes-agent/run_agent.py" 2>/dev/null || true
fi

# 3. Skills
for skill in survey-tab-switch survey-weiter-button survey-cdp-workaround post-survey heypiggy-survey-keyingress-cdp; do
  mkdir -p "$HERMES_HOME/skills/survey/$skill"
  curl -fsSL "$REPO/skills/$skill/SKILL.md" -o "$HERMES_HOME/skills/survey/$skill/SKILL.md" 2>/dev/null || true
done

# 4. 412 Patch
if [ -f "$HERMES_HOME/hermes-agent/agent/error_classifier.py" ]; then
  echo "Applying 412 retry patch..."
  curl -fsSL "$REPO/patches/error_classifier_412.patch" -o /tmp/error_classifier_412.patch
  cd "$HERMES_HOME/hermes-agent"
  git apply /tmp/error_classifier_412.patch 2>/dev/null || echo "Patch may already be applied"
fi

# 5. Set unlimited max_turns (never hit "maximum iterations 90")
if [ -f "$HERMES_HOME/config.yaml" ]; then
  if ! grep -q "max_turns" "$HERMES_HOME/config.yaml"; then
    printf '\nagent:\n  max_turns: 999999\n  max_iterations: 999999\n' >> "$HERMES_HOME/config.yaml"
    echo "Set max_turns=999999 (unlimited)"
  else
    echo "max_turns already set in config.yaml"
  fi
fi

# 6. Auth
echo ""
echo "Setup:"
echo "  hermes auth add custom:fireworks --type api-key --api-key \"\$FIREWORKS_AI_API_KEY\""
echo "  hermes chat -q 'Öffne heypiggy.com, starte Umfrage, beantworte alle Fragen.'"
echo ""
echo "SOP: https://github.com/SIN-CLIs/SIN-Hermes-Bundle/blob/main/docs/survey-run.md"
echo ""
echo "Config: agent.max_turns=999999 (unlimited — no more iteration limits)"
echo "Done!"
