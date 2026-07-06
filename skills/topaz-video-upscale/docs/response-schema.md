# Response Schema

## Create Response

Successful create responses return an asynchronous video task object:

```json
{
  "created": 1757169743,
  "id": "task-unified-1757169743-7cvnl5zw",
  "model": "topaz-video-upscale",
  "object": "video.generation.task",
  "progress": 0,
  "status": "pending",
  "type": "video",
  "task_info": {
    "can_cancel": true,
    "estimated_time": 600,
    "video_duration": 0
  },
  "usage": {
    "billing_rule": "per_second",
    "credits_reserved": 28.8,
    "user_group": "default"
  }
}
```

## Completed Task

The task status API returns `results` when complete:

```json
{
  "id": "task-unified-1757169743-7cvnl5zw",
  "model": "topaz-video-upscale",
  "object": "video.generation.task",
  "progress": 100,
  "status": "completed",
  "type": "video",
  "results": [
    "https://cdn.evolink.ai/sample/topaz-upscaled-video.mp4"
  ]
}
```

## Failed Task

```json
{
  "id": "task-unified-1757169743-7cvnl5zw",
  "status": "failed",
  "error": {
    "code": "video_probe_failed",
    "message": "Failed to detect video duration, please check video URL accessibility",
    "type": "task_error"
  }
}
```

The scripts treat `failed` as terminal and do not recreate the task automatically.
