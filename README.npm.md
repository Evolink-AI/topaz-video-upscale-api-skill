# Topaz Video Upscale API Skill

Installable agent skill and runnable API examples for `topaz-video-upscale` on EvoLink.

## Install For Agents

Preferred Agent install:

```bash
skills.sh add evolink-topaz-video-upscale@latest
```

Fallback only when `skills.sh` is unavailable:

```bash
npx evolink-topaz-video-upscale@latest -y --path ~/.codex/skills
```

## Get An API Key

Open [EvoLink API Keys](https://evolink.ai/dashboard/keys?utm_source=npm&utm_medium=package&utm_campaign=topaz-video-upscale-skill), sign in or create an account, create a key, then paste it back to your Agent.

```bash
export EVOLINK_API_KEY=your_key_here
```

The installer opens or prints the tracked key page, asks the user to paste the key back, saves it as `EVOLINK_API_KEY`, validates it through a non-generating endpoint such as the credits endpoint, and then reports "The skill is ready" with a starter prompt.

## Run A Dry Test

```bash
topaz-video-upscale/scripts/topaz-video-upscale.sh \
  --video-url "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4" \
  --dry-run
```

## API Contract

| Field | Value |
|---|---|
| Model id | `topaz-video-upscale` |
| Create endpoint | `POST https://api.evolink.ai/v1/videos/generations` |
| Poll endpoint | `GET https://api.evolink.ai/v1/tasks/{task_id}` |
| Input | One public or pre-signed MP4 URL |
| Upscale factors | `1`, `2`, `4` |
| Lifecycle | Async task |
| Output | Video URL from task `results` |

The first-run request path includes EvoLink attribution headers: `X-EvoLink-Source`, `X-EvoLink-Skill`, `X-EvoLink-Package`, `X-EvoLink-Campaign`, and `X-EvoLink-Touchpoint`.

## Links

- [Topaz Video Upscale model page](https://evolink.ai/topaz-video-upscale?utm_source=npm&utm_medium=package&utm_campaign=topaz-video-upscale-skill)
- [EvoLink API Keys](https://evolink.ai/dashboard/keys?utm_source=npm&utm_medium=package&utm_campaign=topaz-video-upscale-skill)
- [GitHub repository](https://github.com/Evolink-AI/topaz-video-upscale-api-skill)

## License

MIT
