#!/usr/bin/env python3
"""Static validation for the Topaz Video Upscale API skill repository."""

from __future__ import annotations

import json
from pathlib import Path
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "README.md",
    "SKILL.md",
    "llms-install.md",
    "_meta.json",
    "package.json",
    "bin/cli.js",
    "scripts/topaz-video-upscale.sh",
    "docs/quickstart.md",
    "docs/api-reference.md",
    "docs/task-lifecycle.md",
    "docs/response-schema.md",
    "docs/errors.md",
    "docs/callbacks.md",
    "docs/pricing.md",
    "references/api-params.md",
    "examples/curl/complete-flow.sh",
    "examples/javascript/complete-flow.mjs",
    "examples/python/complete_flow.py",
    "LICENSE",
    ".gitignore",
    ".npmignore",
]

REQUIRED_SNIPPETS = {
    "README.md": [
        "EVOLINK_API_KEY",
        "topaz-video-upscale",
        "POST https://api.evolink.ai/v1/videos/generations",
        "GET https://api.evolink.ai/v1/tasks/{task_id}",
        "npx evolink-topaz-video-upscale",
        "npm publish",
    ],
    "SKILL.md": [
        "name: topaz-video-upscale",
        "scripts/topaz-video-upscale.sh",
        "TASK_SUBMITTED:",
        "VIDEO_URL=",
        "POLL_TIMEOUT:",
        "upscale-factor",
    ],
    "docs/api-reference.md": [
        "video_urls",
        "upscale_factor",
        "callback_url",
    ],
    "docs/response-schema.md": [
        "pending",
        "completed",
        "failed",
        "results",
    ],
    "docs/errors.md": [
        "400",
        "401",
        "402",
        "403",
        "429",
    ],
    "llms-install.md": [
        "{SKILLS_DIR}",
        "npx evolink-topaz-video-upscale@latest",
        "node bin/cli.js -y --path",
    ],
}


def run(cmd: list[str]) -> tuple[int, str]:
    result = subprocess.run(
        cmd,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    return result.returncode, result.stdout.strip()


def main() -> int:
    errors: list[str] = []
    release_mode = "--release" in sys.argv[1:]

    for rel in REQUIRED_FILES:
        path = ROOT / rel
        if not path.is_file():
            errors.append(f"missing file: {rel}")
        elif path.stat().st_size == 0:
            errors.append(f"empty file: {rel}")

    for rel, snippets in REQUIRED_SNIPPETS.items():
        path = ROOT / rel
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8")
        for snippet in snippets:
            if snippet not in text:
                errors.append(f"{rel} missing snippet: {snippet}")
        if "TBD" in text:
            errors.append(f"{rel} contains TBD")

    package = json.loads((ROOT / "package.json").read_text(encoding="utf-8"))
    meta = json.loads((ROOT / "_meta.json").read_text(encoding="utf-8"))
    if package["name"] != "evolink-topaz-video-upscale":
        errors.append("package name mismatch")
    if package["version"] != meta["version"]:
        errors.append("package.json version does not match _meta.json version")
    if meta.get("slug") != "topaz-video-upscale":
        errors.append("_meta.json slug mismatch")
    if meta.get("ownerId") != "Cheer":
        errors.append("_meta.json ownerId must be Cheer")
    if package["bin"].get("evolink-topaz-video-upscale") not in {"bin/cli.js", "./bin/cli.js"}:
        errors.append("package.json bin mismatch")
    if release_mode and not isinstance(meta.get("publishedAt"), int):
        errors.append("_meta.json publishedAt must be an integer timestamp before release")

    commands = [
        ["node", "--check", "bin/cli.js"],
        ["node", "--check", "examples/javascript/complete-flow.mjs"],
        ["bash", "-n", "scripts/topaz-video-upscale.sh"],
        ["bash", "-n", "examples/curl/complete-flow.sh"],
        [sys.executable, "-m", "py_compile", "examples/python/complete_flow.py"],
    ]
    for cmd in commands:
        code, output = run(cmd)
        if code != 0:
            errors.append(f"command failed: {' '.join(cmd)}\n{output}")

    code, output = run([
        "bash",
        "scripts/topaz-video-upscale.sh",
        "--video-url",
        "https://example.com/my-video.mp4",
        "--upscale-factor",
        "4",
        "--dry-run",
    ])
    if code != 0:
        errors.append(f"dry-run failed:\n{output}")
    else:
        for snippet in ['"model": "topaz-video-upscale"', '"upscale_factor": "4"', "video_urls"]:
            if snippet not in output:
                errors.append(f"dry-run output missing snippet: {snippet}")

    if errors:
        print("FAIL")
        for error in errors:
            print(f"- {error}")
        return 1

    print("PASS")
    print(f"root={ROOT}")
    print(f"required_files={len(REQUIRED_FILES)}")
    if release_mode:
        print("release_mode=true")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
