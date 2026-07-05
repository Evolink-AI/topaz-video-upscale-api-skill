# Pricing Notes

The official docs state that Topaz Video Upscale billing is based on input video duration and upscale factor.

This repository intentionally does not hard-code numeric prices. Check the current EvoLink pricing or model page before publishing pricing claims.

Operational guidance:

- Use the shortest useful test video for real smoke tests.
- Prefer `--dry-run` for validation that should not spend API credits.
- Record real smoke-test task ids and results in `.codex/` run evidence.
