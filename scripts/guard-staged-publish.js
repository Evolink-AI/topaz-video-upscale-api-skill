#!/usr/bin/env node

"use strict";

if (process.env.EVOLINK_STAGED_NPM_PUBLISH !== "1") {
  console.error("publish_status=blocked");
  console.error("publish_blocker=Use scripts/publish-npm.sh so README.npm.md is staged as README.md and README.*.md variants are removed before npm publish.");
  process.exit(23);
}
