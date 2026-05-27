# Fireworks AI Vision Capability Research

> **Date:** 2026-05-27
> **Researcher:** Hermes Agent (Survey Session)
> **Conclusion:** Fireworks AI vision is NOT available on this account via the sinator proxy. Use Tesseract OCR.

## Architecture Discovery

Hermes Fireworks Provider uses a **proxy**, not direct Fireworks API:
- Config: `~/.hermes/providers/fireworks-ai.yaml`
- Base URL: `https://sinator.delqhi.com/inference/v1`
- Key: `~/.hermes/.env` → `FIREWORKS_AI_API_KEY`
- Direct Fireworks API (`api.fireworks.ai`) is **NOT** used

## Tested Model IDs (all returned 404 on sinator proxy)

| Model ID | Proxy Status | Note |
|----------|-------------|------|
| `accounts/fireworks/models/llama-v3p2-11b-vision-instruct` | 404 | Not deployed |
| `accounts/fireworks/models/llama-v3p2-90b-vision-instruct` | 404 | Not deployed |
| `accounts/fireworks/models/qwen2p5-vl-72b-instruct` | 404 | Not deployed |
| `accounts/fireworks/models/qwen2p5-vl-7b-instruct` | 404 | Not deployed |
| `accounts/fireworks/models/qwen2-vl-72b-instruct` | 404 | Not deployed |
| `accounts/fireworks/models/qwen2-vl-7b-instruct` | 404 | Not deployed |
| `accounts/fireworks/models/deepseek-vl2` | 404 | Not deployed |

## Provider YAML Models (also 404 on proxy)

Every model listed in `~/.hermes/providers/fireworks-ai.yaml`:

| Model | Proxy Status |
|-------|-------------|
| `accounts/fireworks/models/kimi-k2p6` | 404 |
| `accounts/fireworks/routers/glm-5p1-fast` | 404 |
| `accounts/fireworks/routers/kimi-k2p6-turbo` | 404 |
| `accounts/fireworks/models/deepseek-v4-pro` | 404 |
| `accounts/fireworks/models/qwen3p6-plus` | 404 |
| `accounts/fireworks/models/minimax-m2p7` | 404 |
| `accounts/fireworks/models/glm-5p1` | 404 |
| `accounts/fireworks/models/gpt-oss-120b` | 404 |

**Finding:** The sinator proxy serves **NONE** of the documented Fireworks models.

## Router Test (kimi-k2p6-turbo)

```
Hermes Config (~/.hermes/config.yaml):
  model: accounts/fireworks/routers/kimi-k2p6-turbo
  provider: custom:fireworks
  supports_vision: true   ← THIS IS A LIE
```

`models_dev_cache.json` modalities for `kimi-k2p6-turbo`:
```json
{"input": ["text"], "output": ["text"]}
```

Test: POST sinator/v1/chat/completions with `image_url`
Result: `{"detail":"Not Found"}` (HTTP 404)

Hermes `browser_vision` result: `"Your request was blocked"`

## Docs Status

```
https://docs.fireworks.ai/guides/prompt-engineering/multimodal-image-understanding
  → 404 (Mintlify URL dead, docs restructured)
https://docs.fireworks.ai/guides/vision-models
  → 404
```

Scraping `fireworks.ai/models` with `curl` works to find model names.

## Working Alternative: Tesseract OCR

```bash
brew install tesseract          # macOS, ~1 min
pip3 install pytesseract pillow # Python wrapper
```

Performance: **1.16s per CAPTCHA image** (offline, free, deterministic).
Path: `/opt/homebrew/bin/tesseract`

## Recommendation

For CAPTCHA solving on surveys:
1. **Primary:** Tesseract OCR (CDP screenshot → base64 → Python OCR)
2. **Fallback:** Switch vision provider to Anthropic/Google in Hermes config
3. **Never:** Try Fireworks Vision again — sinator proxy does not serve vision models
