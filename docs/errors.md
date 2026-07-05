# Errors

## HTTP Errors

| Status | Common cause | Fix |
|---:|---|---|
| `400` | Missing `video_urls`, inaccessible source video, or invalid request shape. | Verify the URL is directly accessible and points to an `.mp4`. |
| `401` | Missing, invalid, or expired API key. | Check `EVOLINK_API_KEY` and open [EvoLink API Keys](https://evolink.ai/dashboard/keys?utm_source=github&utm_medium=readme&utm_campaign=topaz-video-upscale-skill). |
| `402` | Insufficient quota. | Add credits from [EvoLink API Keys](https://evolink.ai/dashboard/keys?utm_source=github&utm_medium=readme&utm_campaign=topaz-video-upscale-skill) before retrying. |
| `403` | The key does not have access to `topaz-video-upscale`. | Verify model access on the EvoLink account. |
| `429` | Rate limited. | Wait and retry later. |
| `500` | Server error. | Retry later and keep the request payload for support. |

## Script Errors

| Script line | Meaning |
|---|---|
| `ERROR: EVOLINK_API_KEY is not set` | Set the environment variable before real calls. |
| `ERROR: --video-url is required` | Provide one video URL. |
| `ERROR: --upscale-factor must be 1, 2, or 4` | Use a supported upscale factor. |
| `ERROR: create request failed` | The create HTTP request failed. |
| `ERROR: task query failed` | The polling HTTP request failed. |
| `POLL_TIMEOUT: task_id=<id>` | Local polling ended; the server task may still complete. |

Never submit a second create request just because local polling timed out.
