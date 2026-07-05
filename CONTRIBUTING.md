# Contributing

This repository covers the EvoLink Topaz Video Upscale API and installable agent skill.

## Accepted Changes

- Fix API examples, task polling, error handling, or response parsing.
- Improve agent installation guidance for Hermes Agent, Claude Code, Codex, and compatible agents.
- Correct docs that drift from the EvoLink Topaz Video Upscale API.
- Improve package hygiene without committing local reports or secrets.

## Local Checks

```bash
npm pack --dry-run --json --ignore-scripts
node bin/cli.js --version
scripts/topaz-video-upscale.sh --video-url "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4" --dry-run
```

Real API smoke tests require owner approval, a valid `EVOLINK_API_KEY`, and an explicit cost boundary.
