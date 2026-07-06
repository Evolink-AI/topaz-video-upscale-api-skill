#!/usr/bin/env bash
set -euo pipefail

API_BASE="${EVOLINK_API_BASE:-https://api.evolink.ai}"
MODEL="topaz-video-upscale"
SKILL_SLUG="topaz-video-upscale"
PACKAGE_NAME="evolink-topaz-video-upscale"
CAMPAIGN="topaz-video-upscale-skill"
VIDEO_URL=""
UPSCALE_FACTOR="2"
CALLBACK_URL=""
DRY_RUN="0"
MAX_POLLS="${EVOLINK_TOPAZ_MAX_POLLS:-120}"
POLL_INTERVAL="${EVOLINK_TOPAZ_POLL_INTERVAL:-5}"

usage() {
  cat <<'EOF'
Usage:
  topaz-video-upscale.sh --video-url <mp4-url> [options]

Options:
  --video-url <url>        Required public or pre-signed .mp4 URL; one video per request
  --upscale-factor <n>     1, 2, or 4 (default: 2)
  --callback-url <url>     HTTPS callback URL for completed, failed, or cancelled tasks
  --max-polls <n>          Override poll attempts for this run
  --poll-interval <sec>    Override seconds between polls
  --dry-run                Print payload and exit without calling the API
  --help                   Show help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --video-url) VIDEO_URL="${2:-}"; shift 2 ;;
    --upscale-factor) UPSCALE_FACTOR="${2:-}"; shift 2 ;;
    --callback-url) CALLBACK_URL="${2:-}"; shift 2 ;;
    --max-polls) MAX_POLLS="${2:-}"; shift 2 ;;
    --poll-interval) POLL_INTERVAL="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN="1"; shift ;;
    --help|-h) usage; exit 0 ;;
    *) echo "ERROR: unknown option $1" >&2; usage; exit 2 ;;
  esac
done

if [[ -z "$VIDEO_URL" ]]; then
  echo "ERROR: --video-url is required" >&2
  exit 2
fi
if [[ "$VIDEO_URL" != http://* && "$VIDEO_URL" != https://* ]]; then
  echo "ERROR: --video-url must be an http or https URL" >&2
  exit 2
fi
case "$UPSCALE_FACTOR" in
  1|2|4) ;;
  *) echo "ERROR: --upscale-factor must be 1, 2, or 4" >&2; exit 2 ;;
esac
if [[ -n "$CALLBACK_URL" && "$CALLBACK_URL" != https://* ]]; then
  echo "ERROR: --callback-url must use HTTPS" >&2
  exit 2
fi
if ! [[ "$MAX_POLLS" =~ ^[0-9]+$ ]] || [[ "$MAX_POLLS" -lt 1 ]]; then
  echo "ERROR: --max-polls must be a positive integer" >&2
  exit 2
fi
if ! [[ "$POLL_INTERVAL" =~ ^[0-9]+$ ]] || [[ "$POLL_INTERVAL" -lt 1 ]]; then
  echo "ERROR: --poll-interval must be a positive integer" >&2
  exit 2
fi

PAYLOAD="$(python3 - "$MODEL" "$VIDEO_URL" "$UPSCALE_FACTOR" "$CALLBACK_URL" <<'PY'
import json
import sys

model, video_url, upscale_factor, callback_url = sys.argv[1:]
payload = {
    "model": model,
    "video_urls": [video_url],
    "model_params": {"upscale_factor": str(upscale_factor)},
}
if callback_url:
    payload["callback_url"] = callback_url
print(json.dumps(payload, ensure_ascii=False, indent=2))
PY
)"

if [[ "$DRY_RUN" == "1" ]]; then
  printf '%s\n' "$PAYLOAD"
  exit 0
fi

if [[ -z "${EVOLINK_API_KEY:-}" ]]; then
  echo "ERROR: EVOLINK_API_KEY is not set" >&2
  exit 2
fi

CREATE_RESPONSE="$(curl --silent --show-error --fail-with-body \
  --request POST \
  --url "${API_BASE}/v1/videos/generations" \
  --header "Authorization: Bearer ${EVOLINK_API_KEY}" \
  --header "Content-Type: application/json" \
  --header "X-EvoLink-Source: skill" \
  --header "X-EvoLink-Skill: ${SKILL_SLUG}" \
  --header "X-EvoLink-Package: ${PACKAGE_NAME}" \
  --header "X-EvoLink-Campaign: ${CAMPAIGN}" \
  --header "X-EvoLink-Touchpoint: first-run" \
  --data "$PAYLOAD")" || {
    echo "ERROR: create request failed" >&2
    if [[ -n "${CREATE_RESPONSE:-}" ]]; then
      printf '%s\n' "$CREATE_RESPONSE" >&2
    fi
    exit 1
  }

TASK_ID="$(python3 -c '
import json, sys
data = json.loads(sys.argv[1])
print(data.get("id", ""))
' "$CREATE_RESPONSE")"

if [[ -z "$TASK_ID" ]]; then
  echo "ERROR: create response did not include id" >&2
  printf '%s\n' "$CREATE_RESPONSE" >&2
  exit 1
fi

echo "TASK_SUBMITTED: task_id=${TASK_ID}"

for ((i=1; i<=MAX_POLLS; i++)); do
  TASK_RESPONSE="$(curl --silent --show-error --fail-with-body \
    --request GET \
    --url "${API_BASE}/v1/tasks/${TASK_ID}" \
    --header "Authorization: Bearer ${EVOLINK_API_KEY}")" || {
      echo "ERROR: task query failed" >&2
      if [[ -n "${TASK_RESPONSE:-}" ]]; then
        printf '%s\n' "$TASK_RESPONSE" >&2
      fi
      exit 1
    }

  STATUS="$(python3 -c '
import json, sys
data = json.loads(sys.argv[1])
print(data.get("status", "unknown"))
' "$TASK_RESPONSE")"
  PROGRESS="$(python3 -c '
import json, sys
data = json.loads(sys.argv[1])
print(data.get("progress", ""))
' "$TASK_RESPONSE")"

  if [[ "$STATUS" == "completed" ]]; then
    python3 -c '
import json, sys
data = json.loads(sys.argv[1])
urls = []
for key in ("results", "result_urls"):
    value = data.get(key)
    if isinstance(value, list):
        urls.extend(str(item) for item in value if isinstance(item, str))
for item in data.get("result_data", []) or []:
    if isinstance(item, dict):
        for key in ("video_url", "url"):
            if item.get(key):
                urls.append(str(item[key]))
for url in dict.fromkeys(urls):
    print(f"VIDEO_URL={url}")
print(json.dumps(data, ensure_ascii=False, indent=2))
' "$TASK_RESPONSE"
    echo "TASK_COMPLETED: task_id=${TASK_ID}"
    exit 0
  fi

  if [[ "$STATUS" == "failed" || "$STATUS" == "cancelled" ]]; then
    echo "ERROR: task ended with status=${STATUS}" >&2
    printf '%s\n' "$TASK_RESPONSE" >&2
    exit 1
  fi

  echo "STATUS_UPDATE: status=${STATUS} progress=${PROGRESS}"
  sleep "$POLL_INTERVAL"
done

echo "POLL_TIMEOUT: task_id=${TASK_ID}" >&2
exit 1
