#!/usr/bin/env python3
"""Complete Topaz Video Upscale flow using the Python standard library."""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.request


API_BASE = os.environ.get("EVOLINK_API_BASE", "https://api.evolink.ai")
ATTRIBUTION_HEADERS = {
    "X-EvoLink-Source": "skill",
    "X-EvoLink-Skill": "topaz-video-upscale",
    "X-EvoLink-Package": "evolink-topaz-video-upscale",
    "X-EvoLink-Campaign": "topaz-video-upscale-skill",
    "X-EvoLink-Touchpoint": "first-run",
}


def request_json(method: str, url: str, api_key: str, payload: dict | None = None) -> dict:
    body = None if payload is None else json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=body,
        method=method,
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
            **ATTRIBUTION_HEADERS,
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"non-2xx response {exc.code}: {detail}") from exc


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--video-url", required=True)
    parser.add_argument("--upscale-factor", choices=["1", "2", "4"], default="2")
    parser.add_argument("--max-polls", type=int, default=int(os.environ.get("EVOLINK_TOPAZ_MAX_POLLS", "120")))
    parser.add_argument("--poll-interval", type=int, default=int(os.environ.get("EVOLINK_TOPAZ_POLL_INTERVAL", "5")))
    args = parser.parse_args()

    api_key = os.environ.get("EVOLINK_API_KEY")
    if not api_key:
        print("ERROR: EVOLINK_API_KEY is not set", file=sys.stderr)
        return 2

    payload = {
        "model": "topaz-video-upscale",
        "video_urls": [args.video_url],
        "model_params": {"upscale_factor": args.upscale_factor},
    }
    created = request_json("POST", f"{API_BASE}/v1/videos/generations", api_key, payload)
    task_id = created.get("id")
    if not task_id:
        print(f"ERROR: create response missing id: {created}", file=sys.stderr)
        return 1

    print(f"TASK_SUBMITTED: task_id={task_id}")
    for _ in range(args.max_polls):
        task = request_json("GET", f"{API_BASE}/v1/tasks/{task_id}", api_key)
        status = task.get("status", "unknown")
        print(f"STATUS_UPDATE: status={status} progress={task.get('progress', '')}")
        if status == "completed":
            for url in task.get("results") or []:
                print(f"VIDEO_URL={url}")
            print(f"TASK_COMPLETED: task_id={task_id}")
            return 0
        if status in {"failed", "cancelled"}:
            print(f"ERROR: task ended with status={status}: {json.dumps(task, ensure_ascii=False)}", file=sys.stderr)
            return 1
        time.sleep(args.poll_interval)

    print(f"POLL_TIMEOUT: task_id={task_id}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
