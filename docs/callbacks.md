# Callbacks

Topaz Video Upscale accepts `callback_url`.

Rules from the official docs:

- The URL must use HTTPS.
- Private or internal IP addresses are not allowed.
- URL length must not exceed 2048 characters.
- EvoLink sends callbacks when the task is completed, failed, or cancelled.
- Callback payload is consistent with the task query API.
- A 2xx response is treated as successful.
- Non-2xx responses trigger retry.

Example request:

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
