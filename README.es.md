# Topaz Video Upscale API Skill

API quickstart, runnable examples, and an installable agent skill for `topaz-video-upscale` on EvoLink.

<p align="center">
  <a href="https://docs.evolink.ai/en/api-manual/video-series/topaz/topaz-video-upscale?utm_source=github&utm_medium=readme&utm_campaign=topaz-video-upscale-skill">
    <img src="./assets/banner.jpg" alt="Topaz Video Upscale API and skill guide" width="100%" />
  </a>
</p>

> **AI Agent?** Start with [llms-install.md](llms-install.md), or copy the install command below into your agent.

<a id="menu"></a>

## Menu

- [Agent Skill First](#agent-skill-first)
- [Installation](#installation)
- [Agent Auto-Install](#agent-auto-install)
- [Getting an API Key](#getting-an-api-key)
- [API Quick Start](#api-quick-start)
- [Full First-Run Flow](#full-first-run-flow)
- [API Reference](#api-reference)
- [Showcase](#showcase)
- [Troubleshooting](#troubleshooting)
- [Compatibility](#compatibility)
- [Community](#community)
- [License](#license)

<a id="agent-skill-first"></a>

## Agent Skill First

Use this package when an agent needs to upscale or enhance one public or pre-signed MP4 URL with Topaz Video Upscale through EvoLink.

- Skill slug: `topaz-video-upscale`
- npm package: `evolink-topaz-video-upscale`
- Model id: `topaz-video-upscale`
- Default upscale factor: `2`
- Output: final video URL from the completed async task

<a id="installation"></a>

## Installation

Preferred Agent install:

```bash
skills.sh add evolink-topaz-video-upscale@latest
```

Fallback only when `skills.sh` is unavailable:

```bash
npx evolink-topaz-video-upscale@latest -y --path ~/.codex/skills
```

Manual local install:

```bash
git clone https://github.com/Evolink-AI/topaz-video-upscale-api-skill.git
cd topaz-video-upscale-api-skill
node bin/cli.js -y --path ~/.codex/skills
```

<a id="agent-auto-install"></a>

## Agent Auto-Install

Copy this prompt to an agent:

```text
Install the Topaz Video Upscale skill by running:

skills.sh add evolink-topaz-video-upscale@latest

If skills.sh is unavailable, use:

npx evolink-topaz-video-upscale@latest -y --path ~/.codex/skills

Open the printed EVOLINK_KEY_URL, ask me to paste the key back, save it as EVOLINK_API_KEY, verify it through the non-generating endpoint, then tell me "The skill is ready" and show one starter prompt.
```

<a id="getting-an-api-key"></a>

## Getting an API Key

1. Open [EvoLink API Keys](https://evolink.ai/dashboard/keys?utm_source=github&utm_medium=readme&utm_campaign=topaz-video-upscale-skill).
2. Sign in or create an account on that key page.
3. Create or select a key and paste it back to your agent.
4. Save it for the current shell:

```bash
export EVOLINK_API_KEY=your_key_here
```

The installer prints `EVOLINK_KEY_URL`, `AGENT_NEXT_ACTION`, and `ENV_VAR_EXPORT`. The key must be checked through a non-generating endpoint before any paid generation.

<a id="api-quick-start"></a>

## API Quick Start

```bash
export EVOLINK_API_KEY="your_key_here"

./scripts/topaz-video-upscale.sh \
  --video-url "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4" \
  --upscale-factor 2
```

The script submits an async video task, polls `GET /v1/tasks/{task_id}`, and prints `VIDEO_URL=<url>` when the task completes.

<a id="full-first-run-flow"></a>

## Full First-Run Flow

Dry run without spending API credits:

```bash
./scripts/topaz-video-upscale.sh \
  --video-url "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4" \
  --upscale-factor 4 \
  --dry-run
```

With callback:

```bash
./scripts/topaz-video-upscale.sh \
  --video-url "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4" \
  --callback-url "https://webhook.site/video-task-completed"
```

First-run create requests include `X-EvoLink-Source`, `X-EvoLink-Skill`, `X-EvoLink-Package`, `X-EvoLink-Campaign`, and `X-EvoLink-Touchpoint`.

<a id="api-reference"></a>

## API Reference

| Field | Value |
|---|---|
| Model id | `topaz-video-upscale` |
| Create endpoint | `POST https://api.evolink.ai/v1/videos/generations` |
| Poll endpoint | `GET https://api.evolink.ai/v1/tasks/{task_id}` |
| Input | One public or pre-signed MP4 URL |
| Upscale factors | `1`, `2`, `4` |
| Lifecycle | Async task |
| Output | Video URL from task `results` |

Docs:

- [Quickstart](docs/quickstart.md)
- [API Reference](docs/api-reference.md)
- [Task Lifecycle](docs/task-lifecycle.md)
- [Response Schema](docs/response-schema.md)
- [Errors](docs/errors.md)
- [Callbacks](docs/callbacks.md)
- [Pricing Notes](docs/pricing.md)

<a id="showcase"></a>

## 🖼️ Showcase

| Input | Enhancement | Output |
|---|---|---|
| AI-generated video | 1x cleanup | Cleaner delivery clip |
| Short-form MP4 | 2x upscale | Higher-resolution social asset |
| Production B-roll | 4x upscale | Larger delivery master |

<a id="troubleshooting"></a>

## Troubleshooting

| Issue | Fix |
|---|---|
| `EVOLINK_API_KEY` is missing | Open the tracked key page, paste the key back to the agent, and export it as `EVOLINK_API_KEY`. |
| Skill installed but agent cannot see it | Re-run with the correct `--path` for Codex, Claude Code, Hermes Agent, or compatible agents. |
| `401` or `403` | Validate the key through the non-generating endpoint before retrying a paid call. |
| `POLL_TIMEOUT` | Keep the task id and query later. Do not resubmit the create request automatically. |

<a id="compatibility"></a>

## Compatibility

| Agent | Preferred command |
|---|---|
| Hermes Agent | `skills.sh add evolink-topaz-video-upscale@latest` |
| Claude Code | `skills.sh add evolink-topaz-video-upscale@latest` |
| Codex | `skills.sh add evolink-topaz-video-upscale@latest` |
| OpenClaw | `skills.sh add evolink-topaz-video-upscale@latest` |

<a id="community"></a>

## Community

Use GitHub issues for API docs bugs, installer issues, or example corrections. Do not post API keys, private video URLs, or generated private output in public issues.

## Publication Gate

Republish only after owner approval. Use `scripts/publish-npm.sh`, which stages `README.npm.md` as `README.md`, runs `npm pack --dry-run --json --ignore-scripts`, and then runs `npm publish --access public --auth-type=web` without requesting an OTP.

<p align="center">Powered by EvoLink</p>

<a id="license"></a>

## License

MIT
