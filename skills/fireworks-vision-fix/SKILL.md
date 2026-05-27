---
name: fireworks-vision-fix
title: Fireworks AI Vision Base URL Fix
description: Fixes Fireworks AI vision when browser_vision returns "Your request was blocked" by using correct sinatorpool2 base URL.
version: 1.0.0
metadata:
  hermes:
    tags: [fireworks, vision, config, fix]
    category: devops
---

# Fireworks AI Vision Base URL Fix

## Problem
- `browser_vision` returns: `"Your request was blocked"`
- Direct API tests return HTTP 404 for all models
- Root cause: Wrong base URL in provider config

## Wrong URL (404)
```
https://sinator.delqhi.com/inference/v1
```

## Correct URL (200)
```
https://sinatorpool2.delqhi.com/inference/v1
```

## Files to Fix

### 1. ~/.hermes/providers/fireworks-ai.yaml
```yaml
name: Fireworks AI
base_url: https://sinatorpool2.delqhi.com/inference/v1
api: openai-completions
env_key: FIREWORKS_AI_API_KEY
```

### 2. ~/.hermes/config.yaml (auxiliary vision)
```yaml
auxiliary:
  vision:
    provider: custom:fireworks
    model: accounts/fireworks/routers/kimi-k2p6-turbo
    base_url: 'https://sinatorpool2.delqhi.com/inference/v1'
    api_key: ''
    timeout: 120
```

## Verification
Test with direct API call:
```bash
curl -X POST "https://sinatorpool2.delqhi.com/inference/v1/chat/completions" \
  -H "Authorization: Bearer $FIREWORKS_AI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "accounts/fireworks/routers/kimi-k2p6-turbo",
    "messages": [{
      "role": "user",
      "content": [
        {"type": "text", "text": "What color is this?"},
        {"type": "image_url", "image_url": {"url": "data:image/png;base64,..."}}
      ]
    }]
  }'
```

## Result
- Text API: HTTP 200 ✅
- Vision API: HTTP 200 ✅
- `browser_vision`: Works ✅
- `vision_analyze`: Works ✅