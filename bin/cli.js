#!/usr/bin/env node

"use strict";

const fs = require("fs");
const path = require("path");
const os = require("os");
const { spawnSync } = require("child_process");

const PKG_ROOT = path.resolve(__dirname, "..");
const SKILL_SLUG = "topaz-video-upscale";
const PKG_JSON = JSON.parse(fs.readFileSync(path.join(PKG_ROOT, "package.json"), "utf8"));
const INSTALL_KEY_URL = "https://evolink.ai/dashboard/keys?utm_source=skill&utm_medium=install&utm_campaign=topaz-video-upscale-skill";

function printHelp() {
  console.log(`Topaz Video Upscale Skill Installer v${PKG_JSON.version}

Usage:
  npx evolink-topaz-video-upscale                 interactive installer
  npx evolink-topaz-video-upscale -y              non-interactive installer
  npx evolink-topaz-video-upscale --yes           non-interactive installer
  npx evolink-topaz-video-upscale -y --path <dir> install to a specific skills directory
  npx evolink-topaz-video-upscale --llms          print agent installation guide
  npx evolink-topaz-video-upscale --skill         print SKILL.md
  npx evolink-topaz-video-upscale --no-open       install without opening the API key page
  npx evolink-topaz-video-upscale --version       print version
  npx evolink-topaz-video-upscale --help          show help

Preferred Agent install:
  skills.sh add evolink-topaz-video-upscale@latest

Fallback only when skills.sh is unavailable:
  npx evolink-topaz-video-upscale@latest -y --path <skills-dir>
`);
}

function readFile(rel) {
  process.stdout.write(fs.readFileSync(path.join(PKG_ROOT, rel), "utf8"));
}

function expandHome(p) {
  return p.replace(/^~/, os.homedir());
}

function defaultSkillsDir() {
  const home = os.homedir();
  const candidates = [
    path.join(home, ".codex", "skills"),
    path.join(home, ".claude", "skills"),
    path.join(home, ".hermes", "skills"),
    path.join(home, ".openclaw", "skills")
  ];
  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) return candidate;
  }
  return path.join(home, ".codex", "skills");
}

function copyDir(src, dest) {
  if (!fs.existsSync(src)) return;
  fs.mkdirSync(dest, { recursive: true });
  fs.cpSync(src, dest, { recursive: true });
}

function copyFile(rel, destDir) {
  const src = path.join(PKG_ROOT, rel);
  if (!fs.existsSync(src)) return;
  const dest = path.join(destDir, rel);
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.copyFileSync(src, dest);
}

function commandExists(cmd) {
  const result = spawnSync(os.platform() === "win32" ? "where" : "which", [cmd], {
    stdio: "ignore"
  });
  return result.status === 0;
}

function openUrl(url) {
  const platform = os.platform();
  const command = platform === "darwin" ? "open" : platform === "win32" ? "cmd" : "xdg-open";
  const args = platform === "win32" ? ["/c", "start", "", url] : [url];
  try {
    const result = spawnSync(command, args, {
      stdio: "ignore",
      detached: platform !== "win32"
    });
    return result.error ? { ok: false, reason: result.error.message } : { ok: result.status === 0, reason: result.status === 0 ? "" : `${command} exited ${result.status}` };
  } catch (err) {
    return { ok: false, reason: err.message };
  }
}

function maybeOpenKeyUrl(opts = {}) {
  console.log(`EVOLINK_KEY_URL=${INSTALL_KEY_URL}`);
  console.log("AGENT_NEXT_ACTION=open_key_url_then_collect_key");
  console.log("ENV_VAR_EXPORT=export EVOLINK_API_KEY=your_key_here");
  console.log("KEY_VALIDATION=verify EVOLINK_API_KEY with the non-generating endpoint, such as the credits endpoint; this does not create a generation task.");
  if (opts.noOpen) {
    console.log("--no-open set: not opening a browser.");
    return;
  }
  const opened = openUrl(INSTALL_KEY_URL);
  if (opened.ok) {
    console.log("Opened the EvoLink API key page in your browser.");
  } else {
    console.log(`Could not open browser: ${opened.reason || "unknown error"}`);
    console.log("Open the EVOLINK_KEY_URL above manually.");
  }
}

function install(targetPath, opts = {}) {
  const skillsDir = expandHome(targetPath || defaultSkillsDir());
  const dest = path.join(skillsDir, SKILL_SLUG);
  fs.mkdirSync(dest, { recursive: true });

  for (const file of ["SKILL.md", "llms-install.md", "_meta.json", "LICENSE"]) {
    copyFile(file, dest);
  }
  for (const dir of ["scripts", "references", "docs", "examples"]) {
    copyDir(path.join(PKG_ROOT, dir), path.join(dest, dir));
  }

  const missing = ["curl", "python3"].filter((cmd) => !commandExists(cmd));
  console.log(`Installed ${SKILL_SLUG} to ${dest}`);
  if (missing.length) {
    console.log(`Missing required dependencies: ${missing.join(", ")}`);
  }
  if (!process.env.EVOLINK_API_KEY) {
    console.log("EVOLINK_API_KEY is not set.");
    maybeOpenKeyUrl(opts);
    console.log("Paste the key back to your Agent, save it as EVOLINK_API_KEY, validate it through the non-generating endpoint, then run a dry run before any paid generation.");
  } else {
    console.log("EVOLINK_API_KEY is set. Validate it through the non-generating endpoint before the first paid generation.");
  }
  console.log("The skill is ready after key validation. Starter prompt: Upscale this MP4 URL 2x with Topaz Video Upscale and return the final video URL.");
}

const args = process.argv.slice(2);
if (args.includes("--help") || args.includes("-h")) {
  printHelp();
  process.exit(0);
}
if (args.includes("--version")) {
  console.log(PKG_JSON.version);
  process.exit(0);
}
if (args.includes("--llms")) {
  readFile("llms-install.md");
  process.exit(0);
}
if (args.includes("--skill")) {
  readFile("SKILL.md");
  process.exit(0);
}

let targetPath = null;
const pathIndex = args.indexOf("--path");
if (pathIndex !== -1 && args[pathIndex + 1]) {
  targetPath = args[pathIndex + 1];
}

install(targetPath, { noOpen: args.includes("--no-open") });
