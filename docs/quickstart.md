# Quickstart

Set your EvoLink API key:

```bash
export EVOLINK_API_KEY=your_key_here
```

Run a dry request preview:

```bash
scripts/topaz-video-upscale.sh \
  --video-url "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4" \
  --upscale-factor 2 \
  --dry-run
```

Run a real task:

```bash
scripts/topaz-video-upscale.sh \
  --video-url "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4" \
  --upscale-factor 2
```

Expected flow:

1. The script sends `POST /v1/videos/generations`.
2. The API returns a task id.
3. The script prints `TASK_SUBMITTED: task_id=<id>`.
4. The script polls `GET /v1/tasks/{task_id}`.
5. On completion, the script prints `VIDEO_URL=<url>` and `TASK_COMPLETED: task_id=<id>`.

Do not rerun the create request after `TASK_SUBMITTED:` appears unless the user explicitly asks. Rerun only the task query if you need to check progress.
