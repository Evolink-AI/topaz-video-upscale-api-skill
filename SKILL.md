---
name: topaz-video-upscale
description: Topaz Video Upscale via EvoLink API for Codex, Claude Code, Hermes Agent, and other agents. Use when the user wants to upscale or enhance a video URL with Topaz, choose 1x/2x/4x upscale factors, submit an async video task, poll for completion, handle callbacks, or install/run the EvoLink Topaz Video Upscale skill.
homepage: https://github.com/Evolink-AI/topaz-video-upscale-api-skill
metadata: {"openclaw":{"homepage":"https://github.com/Evolink-AI/topaz-video-upscale-api-skill","requires":{"bins":["curl","python3"],"env":["EVOLINK_API_KEY"]},"primaryEnv":"EVOLINK_API_KEY"}}
---

# Topaz Video Upscale

Use this skill to upscale or enhance one public or pre-signed `.mp4` video URL through EvoLink.

## Script Location

Resolve paths relative to this `SKILL.md`:

```text
SKILL_DIR = directory containing this SKILL.md
SCRIPT = {SKILL_DIR}/scripts/topaz-video-upscale.sh
```

## After Installation

Check whether the API key is present:

```bash
echo $EVOLINK_API_KEY
```

If it is missing, open or show:

```text
EVOLINK_KEY_URL=https://evolink.ai/dashboard/keys?utm_source=skill&utm_medium=install&utm_campaign=topaz-video-upscale-skill
AGENT_NEXT_ACTION=open_key_url_then_collect_key
```

Ask the user to create or select a key, paste it back, and set:

```bash
export EVOLINK_API_KEY=your_key_here
```

Then verify the key through the non-generating endpoint, such as the credits endpoint; this does not create a generation task. After validation, say "The skill is ready" and show a starter prompt.

## Core Principles

- Ask for all missing required inputs in one message.
- Required input is exactly one public or pre-signed `.mp4` URL.
- Default `--upscale-factor` to `2` unless the user asks for enhancement-only `1` or stronger `4`.
- Use `--dry-run` only when the user wants to inspect the request before submission.
- After `TASK_SUBMITTED:` appears, do not rerun automatically; a server-side task already exists.
- Generated video links are time-limited. Tell the user to save the final video promptly.

## Flow

1. Identify the source video URL and requested upscale factor.
2. Check `EVOLINK_API_KEY`. If absent, ask for it before any real API call.
3. Ask all missing required parameters in one message. Do not split required input collection across turns.
4. Execute by agent type:
   - Codex and Claude Code: run the script in the shell and keep reading output until `TASK_COMPLETED:`, `POLL_TIMEOUT:`, or `ERROR:` appears.
   - Hermes Agent and other blocking agents: run the script as a blocking command; the script handles polling internally.

Critical rule: once `TASK_SUBMITTED:` appears, do not rerun the create request unless the user explicitly asks. Query the task instead.

## Script Usage

Basic 2x upscale:

```bash
export EVOLINK_API_KEY=your_key_here

{SKILL_DIR}/scripts/topaz-video-upscale.sh \
  --video-url "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
```

Enhancement only, with no resolution multiplier:

```bash
{SKILL_DIR}/scripts/topaz-video-upscale.sh \
  --video-url "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4" \
  --upscale-factor 1
```

4x upscale:

```bash
{SKILL_DIR}/scripts/topaz-video-upscale.sh \
  --video-url "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4" \
  --upscale-factor 4
```

With callback:

```bash
{SKILL_DIR}/scripts/topaz-video-upscale.sh \
  --video-url "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4" \
  --upscale-factor 2 \
  --callback-url "https://webhook.site/video-task-completed"
```

Dry run:

```bash
{SKILL_DIR}/scripts/topaz-video-upscale.sh \
  --video-url "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4" \
  --dry-run
```

## Script Output Protocol

Parse these lines from stdout or stderr:

| Line | Agent action |
|---|---|
| `TASK_SUBMITTED: task_id=<id>` | Record the task id. Do not rerun automatically. |
| `STATUS_UPDATE: status=<status> progress=<n>` | Keep waiting unless the user asks to stop. |
| `VIDEO_URL=<url>` | Present the video URL and remind the user to save it. |
| `TASK_COMPLETED: task_id=<id>` | Report completion and summarize the output. |
| `POLL_TIMEOUT: task_id=<id>` | Tell the user the server task may still finish; query the task later instead of resubmitting. |
| `ERROR: ...` | Surface a friendly error and suggest the smallest fix. |

## Error Handling

| Error | Friendly response |
|---|---|
| `EVOLINK_API_KEY is not set` | Ask the user to set `EVOLINK_API_KEY` before a real run. |
| `--video-url is required` | Ask for one directly accessible `.mp4` URL. |
| `--upscale-factor must be 1, 2, or 4` | Ask the user to choose 1, 2, or 4; default to 2. |
| `create request failed` | Check the API key, request payload, video URL accessibility, and quota. Use `--dry-run` to inspect the payload. |
| `task query failed` | Keep the task id and retry only the query endpoint later. Do not recreate the task. |
| `POLL_TIMEOUT` | Explain that local polling ended and the task may still complete server-side. |

## Model Capabilities Summary

Topaz Video Upscale accepts one directly accessible `.mp4` URL per request, supports `1`, `2`, and `4` upscale factors, runs asynchronously, and returns task results through polling or a callback. Use `1` for enhancement only, `2` as the default upscale, and `4` for stronger resolution multiplication.

## References

- `scripts/topaz-video-upscale.sh`
- `docs/quickstart.md`
- `docs/api-reference.md`
- `docs/task-lifecycle.md`
- `docs/response-schema.md`
- `docs/errors.md`
- `docs/callbacks.md`
- `references/api-params.md`
