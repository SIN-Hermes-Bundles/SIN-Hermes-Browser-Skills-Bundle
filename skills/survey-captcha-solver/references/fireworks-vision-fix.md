# Fireworks AI Vision: The Fix (2026-05-27)

## The Problem
- `browser_vision`: "Your request was blocked"
- `vision_analyze`: "Error analyzing image: Your request was blocked"
- Direct API tests: HTTP 404 on all models
- Hermes config said `supports_vision: true` but vision didn't work

## Root Cause: Wrong Base URL
Fireworks Provider in Hermes was pointed at the OLD sinator proxy:
```
WRONG: https://sinator.delqhi.com/inference/v1     → HTTP 404 for everything
RIGHT: https://sinatorpool2.delqhi.com/inference/v1  → HTTP 200 ✅
```

## Files Changed
1. `~/.hermes/providers/fireworks-ai.yaml`: `base_url` updated
2. `~/.hermes/config.yaml` (auxiliary.vision): `base_url` set explicitly

## Model Capabilities (sinatorpool2)
| Model | Text | Vision |
|-------|------|--------|
| `accounts/fireworks/routers/kimi-k2p6-turbo` | ✅ HTTP 200 | ✅ HTTP 200 |
| `accounts/fireworks/models/qwen3-vl-235b-a22b-instruct` | ❌ 404 | ❌ 404 |
| `accounts/fireworks/models/gemma-4-31b-it` | ❌ 404 | ❌ 404 |

**Conclusion:** Only kimi-k2p6-turbo is available on sinatorpool2. It supports vision.

## Verification (direct API)
```bash
curl -X POST "https://sinatorpool2.delqhi.com/inference/v1/chat/completions" \
  -H "Authorization: Bearer $KEY" \
  -d '{"model":"accounts/fireworks/routers/kimi-k2p6-turbo",
       "messages":[{"role":"user","content":[{"type":"text","text":"What color?"},
         {"type":"image_url","image_url":{"url":"data:image/png;base64,..."}}]}]}'
# → HTTP 200 ✅
```

## Latency
browser_vision over sinatorpool2: ~8s (screenshot + base64 + proxy + LLM + response)
Tesseract OCR: ~1.2s (local, no network)
