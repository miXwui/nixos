# AI / LLM development environment

Local LLM inference stack running on AMD 7840U (Radeon 780M) via Vulkan.

## Stack

### llama-cpp

Compiled with `vulkanSupport = true` for GPU acceleration on the integrated
RDNA3 graphics. Also provides `llama-bench`, `llama-server`, etc.

- ROCm: not used. Brief testing showed Vulkan is currently faster on 780M.
- See `modules/nixos/development/ai.nix` for override details.

### llama-swap

Model router on port **8080**. Loads models on demand and swaps between them.

Configured models:

| Model           | Params | Active | Notes                            |
| --------------- | ------ | ------ | -------------------------------- |
| Qwen3.6-35B-A3B | 35B    | 3B     | Default, MTP spec-decode enabled |
| Gemma-4-12B-QAT | 12B    | 12B    | With MTP draft model, TTL 300s   |

All model files live in `/var/lib/llama-swap/`. GPU shader cache at
`/var/cache/llama-swap` (persisted across rebuilds).

### Open WebUI

Web frontend on port **12345**. Points at llama-swap's OpenAI-compatible
endpoint. Auth disabled, telemetry off.

## Usage

```sh
# Open WebUI
xdg-open http://localhost:12345

# Check llama-swap status
curl http://localhost:8080/health

# List loaded models
curl http://localhost:8080/v1/models
```

## Todo

- Test Claude 4.7 Opus Reasoning Distilled APEX-MTP quant for quality comparison
  (see `modules/nixos/development/ai.nix` for the commented-out config).
