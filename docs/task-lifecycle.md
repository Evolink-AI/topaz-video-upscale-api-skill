# Task Lifecycle

Topaz Video Upscale is asynchronous.

## States

| Status | Meaning |
|---|---|
| `pending` | Task was accepted and is waiting to process. |
| `processing` | Upscaling is in progress. |
| `completed` | Results are available in the task response. |
| `failed` | The task ended with an error. |

## Polling

Poll:

```http
GET https://api.evolink.ai/v1/tasks/{task_id}
```

The bundled script polls until:

- `completed`: prints `VIDEO_URL=<url>` and exits 0.
- `failed` or `cancelled`: prints the task response to stderr and exits 1.
- max polls are reached: prints `POLL_TIMEOUT: task_id=<id>` and exits 1.

`POLL_TIMEOUT` does not prove the server task failed. Keep the task id and query later.
