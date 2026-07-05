# Topaz Video Upscale Parameters

## Required

| Parameter | Type | Notes |
|---|---|---|
| `model` | string | Must be `topaz-video-upscale`. |
| `video_urls` | array of string URLs | Exactly one directly accessible `.mp4` URL. |

## Optional

| Parameter | Type | Default | Notes |
|---|---|---|---|
| `model_params.upscale_factor` | string or number | `2` | Accepts `1`, `2`, or `4`. |
| `callback_url` | string URL | none | HTTPS callback endpoint. |

## Upscale Factors

| Factor | Use |
|---|---|
| `1` | Enhancement only; no resolution multiplier. |
| `2` | Default 2x upscale. |
| `4` | Stronger upscale with higher cost. |

The official docs state invalid upscale factor values fall back to the default. The bundled script validates locally instead so user mistakes are visible before spending API credits.
