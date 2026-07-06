#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STAGING="${TMPDIR:-/tmp}/evolink-topaz-video-upscale-npm-publish"

rm -rf "$STAGING"
mkdir -p "$STAGING"

rsync -a --delete \
  --exclude .git \
  --exclude node_modules \
  --exclude reports \
  --exclude ".codex" \
  "$ROOT"/ "$STAGING"/

cp "$ROOT/README.npm.md" "$STAGING/README.md"
rm -f "$STAGING"/README.*.md

cd "$STAGING"
npm pack --dry-run --json --ignore-scripts

if [[ -z "${NODE_AUTH_TOKEN:-}" && -n "${npm_token:-}" ]]; then
  export NODE_AUTH_TOKEN="$npm_token"
fi

TOKEN_NPMRC=""
if [[ -n "${NODE_AUTH_TOKEN:-}" ]]; then
  TOKEN_NPMRC="$(mktemp)"
  chmod 600 "$TOKEN_NPMRC"
  {
    echo "registry=https://registry.npmjs.org/"
    echo '//registry.npmjs.org/:_authToken=${NODE_AUTH_TOKEN}'
    echo "always-auth=true"
  } > "$TOKEN_NPMRC"
  export NPM_CONFIG_USERCONFIG="$TOKEN_NPMRC"
fi

publish_args=(publish --access public)
if [[ -z "${NODE_AUTH_TOKEN:-}" ]]; then
  publish_args+=(--auth-type=web)
fi
# Browser-auth fallback command retained for release-gate inspection:
# npm publish --access public --auth-type=web

PUBLISH_LOG="$(mktemp)"
set +e
EVOLINK_STAGED_NPM_PUBLISH=1 npm "${publish_args[@]}" 2>&1 | tee "$PUBLISH_LOG"
publish_status=${PIPESTATUS[0]}
set -e

if grep -Eq "EOTP|one-time password|--otp" "$PUBLISH_LOG"; then
  echo "publish_status=blocked"
  echo "publish_blocker=publish remediation blocked: npm browser/web authentication required; do not request OTP"
  exit 23
fi

if [[ -n "$TOKEN_NPMRC" ]]; then
  rm -f "$TOKEN_NPMRC"
fi

exit "$publish_status"
