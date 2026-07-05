# Topaz Video Upscale Agent Install Guide

Use this guide when an AI agent needs to install and run the skill.

## One-Liner

```bash
skills.sh add evolink-topaz-video-upscale@latest
```

Use `npx evolink-topaz-video-upscale@latest -y --path {SKILLS_DIR}` only as a fallback when `skills.sh` is unavailable.

Replace `{SKILLS_DIR}` with the target agent skill directory:

- Codex: `~/.codex/skills`
- Claude Code: `~/.claude/skills`
- Hermes Agent: `~/.hermes/skills`
- OpenClaw: `~/.openclaw/skills`

## Local Repository Install

Before npm publication, install from this repository:

```bash
node bin/cli.js -y --path {SKILLS_DIR}
```

Then read:

```bash
cat {SKILLS_DIR}/topaz-video-upscale/SKILL.md
```

## API Key

Check for the key:

```bash
echo $EVOLINK_API_KEY
```

If it is empty, ask the user for an EvoLink API key from:

```text
https://evolink.ai/dashboard/keys?utm_source=skill&utm_medium=install&utm_campaign=topaz-video-upscale-skill
```

Then set:

```bash
export EVOLINK_API_KEY=your_key_here
```

Machine-readable handoff:

```text
EVOLINK_KEY_URL=https://evolink.ai/dashboard/keys?utm_source=skill&utm_medium=install&utm_campaign=topaz-video-upscale-skill
AGENT_NEXT_ACTION=open_key_url_then_collect_key
ENV_VAR_EXPORT=export EVOLINK_API_KEY=your_key_here
KEY_VALIDATION=verify EVOLINK_API_KEY with the non-generating endpoint, such as the credits endpoint; this does not create a generation task.
```

After the user pastes the key, save it as `EVOLINK_API_KEY`, verify it through the non-generating endpoint, then tell the user: "The skill is ready" and show a starter prompt.

## Verify Installation

```bash
{SKILLS_DIR}/topaz-video-upscale/scripts/topaz-video-upscale.sh \
  --video-url "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4" \
  --dry-run
```

The dry run should print JSON containing:

```json
{
  "model": "topaz-video-upscale",
  "video_urls": ["https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"],
  "model_params": {"upscale_factor": "2"}
}
```

## Publication Gate

Publication is owner-controlled. If republishing is approved, use `scripts/publish-npm.sh`; it stages `README.npm.md` as `README.md`, runs `npm pack --dry-run --json --ignore-scripts`, and publishes with `npm publish --access public --auth-type=web` without requesting an OTP.
