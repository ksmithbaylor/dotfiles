#!/usr/bin/env node
//
// Run one round of a Codex review conversation.
//
//   codex-round.mjs <state-dir> <prompt-file>
//
// The first call starts a Codex thread and records its id. Every later call
// resumes that same thread, so Codex keeps the whole review in context instead
// of meeting the code fresh each round.
//
// Prints the path to Codex's JSON verdict for this round.
//
// This talks to `codex app-server` over JSON-RPC rather than shelling out to
// `codex exec`. Reasoning effort is only settable per turn on this protocol:
// `codex exec` has no flag for it, and ignores both `model_reasoning_effort` in
// config.toml and `-c` overrides of it.

import { spawn } from "node:child_process";
import { createInterface } from "node:readline";
import { appendFileSync, existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const MODEL = "gpt-6-sol";
const EFFORT = "xhigh";

const skillDir = join(dirname(fileURLToPath(import.meta.url)), "..");
const schemaPath = join(skillDir, "reference", "verdict-schema.json");

class CodexAppServer {
  #proc;
  #pending = new Map();
  #nextId = 1;
  #onNotification = () => {};
  #onClose = () => {};
  #stderr = "";
  #exit = null;
  #closing = false;

  async open(cwd) {
    this.#proc = spawn("codex", ["app-server"], { cwd, stdio: ["pipe", "pipe", "pipe"] });
    this.#proc.stdout.setEncoding("utf8");
    this.#proc.stderr.setEncoding("utf8");
    this.#proc.stderr.on("data", (chunk) => {
      this.#stderr += chunk;
    });
    this.#proc.on("exit", (code, signal) => {
      this.#fail(new Error(`codex app-server exited (${signal ?? code})\n${this.#stderr.trim()}`));
    });
    this.#proc.on("error", (error) => this.#fail(error));

    createInterface({ input: this.#proc.stdout }).on("line", (line) => this.#receive(line));

    await this.request("initialize", {
      clientInfo: { title: "codex-review-loop", name: "Claude Code", version: "1.0.0" },
      capabilities: {
        experimentalApi: false,
        requestAttestation: false,
        optOutNotificationMethods: [
          "item/agentMessage/delta",
          "item/reasoning/summaryTextDelta",
          "item/reasoning/summaryPartAdded",
          "item/reasoning/textDelta"
        ]
      }
    });
    this.#send({ jsonrpc: "2.0", method: "initialized", params: {} });
  }

  request(method, params) {
    const id = this.#nextId++;
    this.#send({ jsonrpc: "2.0", id, method, params });
    return new Promise((resolve, reject) => this.#pending.set(id, { method, resolve, reject }));
  }

  onNotification(handler) {
    this.#onNotification = handler;
  }

  // Called only when the server dies on its own, never on an intended close.
  onClose(handler) {
    this.#onClose = handler;
  }

  close() {
    this.#closing = true;
    this.#proc?.stdin.end();
    this.#proc?.kill();
  }

  get stderr() {
    return this.#stderr.trim();
  }

  #send(message) {
    this.#proc.stdin.write(`${JSON.stringify(message)}\n`);
  }

  #receive(line) {
    if (!line.trim()) return;
    let message;
    try {
      message = JSON.parse(line);
    } catch {
      return;
    }

    if (message.id !== undefined && this.#pending.has(message.id)) {
      const { method, resolve, reject } = this.#pending.get(message.id);
      this.#pending.delete(message.id);
      if (message.error) reject(new Error(`codex ${method} failed: ${message.error.message}`));
      else resolve(message.result ?? {});
      return;
    }

    if (message.method) this.#onNotification(message);
  }

  #fail(error) {
    if (this.#exit) return;
    this.#exit = error;
    for (const { reject } of this.#pending.values()) reject(error);
    this.#pending.clear();
    if (!this.#closing) this.#onClose(error);
  }
}

// Resolves once Codex finishes the turn, with the text of its final message.
function runTurn(codex, threadId, prompt, eventsPath) {
  return new Promise((resolve, reject) => {
    let finalMessage = "";

    codex.onClose(reject);
    codex.onNotification((message) => {
      appendFileSync(eventsPath, `${JSON.stringify(message)}\n`);
      const params = message.params ?? {};
      if (params.threadId && params.threadId !== threadId) return;

      switch (message.method) {
        case "item/completed":
          if (params.item?.type === "agentMessage" && params.item.text) finalMessage = params.item.text;
          break;
        case "turn/completed":
          if (params.turn?.status === "completed") resolve(finalMessage);
          else reject(new Error(`turn ended as ${params.turn?.status ?? "unknown"}`));
          break;
        case "error":
          reject(new Error(params.error?.message ?? "codex reported an error"));
          break;
      }
    });

    codex
      .request("turn/start", {
        threadId,
        input: [{ type: "text", text: prompt, text_elements: [] }],
        model: MODEL,
        effort: EFFORT,
        outputSchema: JSON.parse(readFileSync(schemaPath, "utf8"))
      })
      .catch(reject);
  });
}

async function openThread(codex, cwd, threadFile) {
  const settings = { cwd, model: MODEL, approvalPolicy: "never", sandbox: "read-only" };

  if (existsSync(threadFile)) {
    const threadId = readFileSync(threadFile, "utf8").trim();
    await codex.request("thread/resume", { threadId, ...settings });
    return threadId;
  }

  const started = await codex.request("thread/start", { ...settings, ephemeral: false });
  const threadId = started.thread?.id;
  if (!threadId) throw new Error("codex reported no thread id");
  writeFileSync(threadFile, `${threadId}\n`);
  return threadId;
}

async function main() {
  const [stateDir, promptFile] = process.argv.slice(2);
  if (!stateDir || !promptFile) {
    console.error("usage: codex-round.mjs <state-dir> <prompt-file>");
    process.exit(1);
  }
  if (!existsSync(promptFile)) {
    console.error(`no such prompt file: ${promptFile}`);
    process.exit(1);
  }
  mkdirSync(stateDir, { recursive: true });

  const round =
    readdirSync(stateDir).filter((name) => /^round-\d+-verdict\.json$/.test(name)).length + 1;
  const eventsPath = join(stateDir, `round-${round}-events.jsonl`);
  const verdictPath = join(stateDir, `round-${round}-verdict.json`);
  writeFileSync(eventsPath, "");

  const codex = new CodexAppServer();
  let finalMessage;
  try {
    await codex.open(process.cwd());
    const threadId = await openThread(codex, process.cwd(), join(stateDir, "thread-id"));
    finalMessage = await runTurn(codex, threadId, readFileSync(promptFile, "utf8"), eventsPath);
  } catch (error) {
    console.error(`round ${round} failed: ${error.message}`);
    console.error(`see ${eventsPath}`);
    process.exit(1);
  } finally {
    codex.close();
  }

  try {
    JSON.parse(finalMessage);
  } catch {
    console.error(`round ${round} produced no valid verdict; see ${eventsPath}`);
    process.exit(1);
  }
  writeFileSync(verdictPath, finalMessage.endsWith("\n") ? finalMessage : `${finalMessage}\n`);
  console.log(verdictPath);
}

await main();
