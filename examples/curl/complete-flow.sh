#!/usr/bin/env bash
set -euo pipefail

VIDEO_URL="${1:-}"
UPSCALE_FACTOR="${2:-2}"
SKILL_SLUG="topaz-video-upscale"
PACKAGE_NAME="evolink-topaz-video-upscale"
CAMPAIGN="topaz-video-upscale-skill"
MAX_POLLS="${EVOLINK_TOPAZ_MAX_POLLS:-120}"
POLL_INTERVAL="${EVOLINK_TOPAZ_POLL_INTERVAL:-5}"

if [[ -z "${EVOLINK_API_KEY:-}" ]]; then
  echo "ERROR: EVOLINK_API_KEY is not set" >&2
  exit 2
fi
if [[ -z "$VIDEO_URL" ]]; then
  echo "Usage: $0 <mp4-url> [1|2|4]" >&2
  exit 2
fi
case "$UPSCALE_FACTOR" in
  1|2|4) ;;
  *) echo "ERROR: upscale factor must be 1, 2, or 4" >&2; exit 2 ;;
esac

PAYLOAD="$(python3 - "$VIDEO_URL" "$UPSCALE_FACTOR" <<'PY'
import json
import sys
video_url, factor = sys.argv[1:]
print(json.dumps({
    "model": "topaz-video-upscale",
    "video_urls": [video_url],
    "model_params": {"upscale_factor": str(factor)}
}, indent=2))
PY
)"

CREATE_RESPONSE="$(curl --silent --show-error --fail-with-body \
  --request POST \
  --url "https://api.evolink.ai/v1/videos/generations" \
  --header "Authorization: Bearer ${EVOLINK_API_KEY}" \
  --header "Content-Type: application/json" \
  --header "X-EvoLink-Source: skill" \
  --header "X-EvoLink-Skill: ${SKILL_SLUG}" \
  --header "X-EvoLink-Package: ${PACKAGE_NAME}" \
  --header "X-EvoLink-Campaign: ${CAMPAIGN}" \
  --header "X-EvoLink-Touchpoint: first-run" \
  --data "$PAYLOAD")" || {
    echo "ERROR: non-2xx create response" >&2
    if [[ -n "${CREATE_RESPONSE:-}" ]]; then
      printf '%s\n' "$CREATE_RESPONSE" >&2
    fi
    exit 1
  }

TASK_ID="$(python3 -c 'import json,sys; print(json.loads(sys.argv[1]).get("id",""))' "$CREATE_RESPONSE")"
if [[ -z "$TASK_ID" ]]; then
  echo "ERROR: create response missing id" >&2
  printf '%s\n' "$CREATE_RESPONSE" >&2
  exit 1
fi

echo "TASK_SUBMITTED: task_id=${TASK_ID}"

for ((i=1; i<=MAX_POLLS; i++)); do
  TASK_RESPONSE="$(curl --silent --show-error --fail-with-body \
    --request GET \
    --url "https://api.evolink.ai/v1/tasks/${TASK_ID}" \
    --header "Authorization: Bearer ${EVOLINK_API_KEY}")" || {
      echo "ERROR: non-2xx task query response" >&2
      if [[ -n "${TASK_RESPONSE:-}" ]]; then
        printf '%s\n' "$TASK_RESPONSE" >&2
      fi
      exit 1
    }

  STATUS="$(python3 -c 'import json,sys; print(json.loads(sys.argv[1]).get("status","unknown"))' "$TASK_RESPONSE")"
  PROGRESS="$(python3 -c 'import json,sys; print(json.loads(sys.argv[1]).get("progress",""))' "$TASK_RESPONSE")"
  echo "STATUS_UPDATE: status=${STATUS} progress=${PROGRESS}"

  if [[ "$STATUS" == "completed" ]]; then
    python3 -c '
import json, sys
data = json.loads(sys.argv[1])
for url in data.get("results", []) or []:
    print(f"VIDEO_URL={url}")
' "$TASK_RESPONSE"
    echo "TASK_COMPLETED: task_id=${TASK_ID}"
    exit 0
  fi
  if [[ "$STATUS" == "failed" || "$STATUS" == "cancelled" ]]; then
    echo "ERROR: task ended with status=${STATUS}" >&2
    printf '%s\n' "$TASK_RESPONSE" >&2
    exit 1
  fi
  sleep "$POLL_INTERVAL"
done

echo "POLL_TIMEOUT: task_id=${TASK_ID}" >&2
exit 1
