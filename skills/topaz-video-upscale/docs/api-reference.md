# API Reference

Source: official EvoLink Topaz Video Upscale documentation.

## Authentication

All requests use Bearer token authentication:

```http
Authorization: Bearer YOUR_API_KEY
```

The repository scripts read the key from `EVOLINK_API_KEY`.

## Create Video Upscale Task

```http
POST https://api.evolink.ai/v1/videos/generations
Content-Type: application/json
Authorization: Bearer YOUR_API_KEY
```

Request body:

```json
{
  "model": "topaz-video-upscale",
  "video_urls": ["https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"],
  "model_params": {
    "upscale_factor": "2"
  }
}
```

With callback:

```json
{
  "model": "topaz-video-upscale",
  "video_urls": ["https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"],
  "model_params": {
    "upscale_factor": "2"
  },
  "callback_url": "https://webhook.site/video-task-completed"
}
```

## Query Task

```http
GET https://api.evolink.ai/v1/tasks/{task_id}
Authorization: Bearer YOUR_API_KEY
```

The `task_id` is the `id` returned by the create response.

## Constraints

- `video_urls` is required.
- Only one video URL is accepted per request.
- The video URL must be directly accessible by EvoLink.
- The supported source format documented for this model is `.mp4`.
- `upscale_factor` accepts `1`, `2`, or `4`; default is `2`.
- Final video links are time-limited and should be saved promptly.
