#!/usr/bin/env node

const API_BASE = process.env.EVOLINK_API_BASE || "https://api.evolink.ai";

function argValue(name) {
  const index = process.argv.indexOf(name);
  return index === -1 ? "" : (process.argv[index + 1] || "");
}

const videoUrl = argValue("--video-url");
const upscaleFactor = argValue("--upscale-factor") || "2";
const maxPolls = Number(argValue("--max-polls") || process.env.EVOLINK_TOPAZ_MAX_POLLS || 120);
const pollInterval = Number(argValue("--poll-interval") || process.env.EVOLINK_TOPAZ_POLL_INTERVAL || 5);

if (!process.env.EVOLINK_API_KEY) {
  console.error("ERROR: EVOLINK_API_KEY is not set");
  process.exit(2);
}
if (!videoUrl) {
  console.error("Usage: node complete-flow.mjs --video-url <mp4-url> [--upscale-factor 1|2|4]");
  process.exit(2);
}
if (!["1", "2", "4"].includes(upscaleFactor)) {
  console.error("ERROR: --upscale-factor must be 1, 2, or 4");
  process.exit(2);
}

async function requestJson(method, url, payload) {
  const response = await fetch(url, {
    method,
    headers: {
      Authorization: `Bearer ${process.env.EVOLINK_API_KEY}`,
      "Content-Type": "application/json",
      "X-EvoLink-Source": "skill",
      "X-EvoLink-Skill": "topaz-video-upscale",
      "X-EvoLink-Package": "evolink-topaz-video-upscale",
      "X-EvoLink-Campaign": "topaz-video-upscale-skill",
      "X-EvoLink-Touchpoint": "first-run"
    },
    body: payload ? JSON.stringify(payload) : undefined
  });
  const text = await response.text();
  if (!response.ok) {
    throw new Error(`non-2xx response ${response.status}: ${text}`);
  }
  return JSON.parse(text);
}

const payload = {
  model: "topaz-video-upscale",
  video_urls: [videoUrl],
  model_params: { upscale_factor: upscaleFactor }
};

const created = await requestJson("POST", `${API_BASE}/v1/videos/generations`, payload);
const taskId = created.id;
if (!taskId) {
  throw new Error(`create response missing id: ${JSON.stringify(created)}`);
}
console.log(`TASK_SUBMITTED: task_id=${taskId}`);

for (let i = 0; i < maxPolls; i += 1) {
  const task = await requestJson("GET", `${API_BASE}/v1/tasks/${taskId}`);
  const status = task.status || "unknown";
  console.log(`STATUS_UPDATE: status=${status} progress=${task.progress ?? ""}`);
  if (status === "completed") {
    for (const url of task.results || []) {
      console.log(`VIDEO_URL=${url}`);
    }
    console.log(`TASK_COMPLETED: task_id=${taskId}`);
    process.exit(0);
  }
  if (status === "failed" || status === "cancelled") {
    console.error(`ERROR: task ended with status=${status}: ${JSON.stringify(task)}`);
    process.exit(1);
  }
  await new Promise((resolve) => setTimeout(resolve, pollInterval * 1000));
}

console.error(`POLL_TIMEOUT: task_id=${taskId}`);
process.exit(1);
