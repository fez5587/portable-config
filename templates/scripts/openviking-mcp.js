#!/usr/bin/env node
"use strict";

const BASE_URL = (process.env.OPENVIKING_BASE_URL || "http://127.0.0.1:1933").replace(/\/+$/, "");
const SEARCH_PATHS = (process.env.OPENVIKING_SEARCH_PATHS || "/api/v1/search,/find")
  .split(",")
  .map((s) => s.trim())
  .filter(Boolean);
const READ_PATHS = (process.env.OPENVIKING_READ_PATHS || "/api/v1/read,/read")
  .split(",")
  .map((s) => s.trim())
  .filter(Boolean);
const UPSERT_PATHS = (process.env.OPENVIKING_UPSERT_PATHS || "/api/v1/add_resource,/add_resource")
  .split(",")
  .map((s) => s.trim())
  .filter(Boolean);

function writeMessage(msg) {
  const body = Buffer.from(JSON.stringify(msg), "utf8");
  process.stdout.write(`Content-Length: ${body.length}\r\n\r\n`);
  process.stdout.write(body);
}

async function postWithFallback(paths, payload) {
  let lastError = null;
  for (const path of paths) {
    try {
      const res = await fetch(`${BASE_URL}${path}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });
      if (!res.ok) {
        const text = await res.text();
        lastError = new Error(`HTTP ${res.status} on ${path}: ${text.slice(0, 400)}`);
        continue;
      }
      return await res.json();
    } catch (err) {
      lastError = err;
    }
  }
  throw lastError || new Error("All endpoint attempts failed");
}

function makeTools() {
  return [
    {
      name: "openviking_search",
      description: "Search OpenViking memory/context and return top matches.",
      inputSchema: {
        type: "object",
        properties: {
          query: { type: "string", description: "Search query." },
          top_k: { type: "integer", minimum: 1, maximum: 20, default: 5 },
          namespace: { type: "string", description: "Optional namespace/project bucket." },
        },
        required: ["query"],
      },
    },
    {
      name: "openviking_read",
      description: "Read a resource from OpenViking by URI or ID.",
      inputSchema: {
        type: "object",
        properties: {
          uri: { type: "string" },
          id: { type: "string" },
          namespace: { type: "string" },
        },
      },
    },
    {
      name: "openviking_upsert",
      description: "Add or update a memory resource in OpenViking.",
      inputSchema: {
        type: "object",
        properties: {
          id: { type: "string" },
          uri: { type: "string" },
          title: { type: "string" },
          content: { type: "string" },
          namespace: { type: "string" },
          metadata: { type: "object" },
        },
        required: ["content"],
      },
    },
  ];
}

async function handleToolCall(name, args) {
  if (name === "openviking_search") {
    const payload = {
      query: args.query,
      top_k: args.top_k ?? 5,
      namespace: args.namespace,
    };
    const data = await postWithFallback(SEARCH_PATHS, payload);
    return {
      content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
    };
  }
  if (name === "openviking_read") {
    const payload = {
      uri: args.uri,
      id: args.id,
      namespace: args.namespace,
    };
    const data = await postWithFallback(READ_PATHS, payload);
    return {
      content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
    };
  }
  if (name === "openviking_upsert") {
    const payload = {
      id: args.id,
      uri: args.uri,
      title: args.title,
      content: args.content,
      namespace: args.namespace,
      metadata: args.metadata,
    };
    const data = await postWithFallback(UPSERT_PATHS, payload);
    return {
      content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
    };
  }
  throw new Error(`Unknown tool: ${name}`);
}

async function onRequest(msg) {
  const { id, method, params } = msg;
  try {
    if (method === "initialize") {
      writeMessage({
        jsonrpc: "2.0",
        id,
        result: {
          protocolVersion: "2024-11-05",
          serverInfo: { name: "openviking-mcp-bridge", version: "0.1.0" },
          capabilities: { tools: {} },
        },
      });
      return;
    }
    if (method === "notifications/initialized") {
      return;
    }
    if (method === "tools/list") {
      writeMessage({
        jsonrpc: "2.0",
        id,
        result: { tools: makeTools() },
      });
      return;
    }
    if (method === "tools/call") {
      const toolName = params?.name;
      const args = params?.arguments || {};
      const result = await handleToolCall(toolName, args);
      writeMessage({ jsonrpc: "2.0", id, result });
      return;
    }
    writeMessage({
      jsonrpc: "2.0",
      id,
      error: { code: -32601, message: `Method not found: ${method}` },
    });
  } catch (err) {
    writeMessage({
      jsonrpc: "2.0",
      id,
      error: { code: -32000, message: err && err.message ? err.message : String(err) },
    });
  }
}

let buffer = Buffer.alloc(0);
process.stdin.on("data", (chunk) => {
  buffer = Buffer.concat([buffer, chunk]);
  while (true) {
    const headerEnd = buffer.indexOf("\r\n\r\n");
    if (headerEnd === -1) break;
    const headerText = buffer.slice(0, headerEnd).toString("utf8");
    const match = headerText.match(/Content-Length:\s*(\d+)/i);
    if (!match) {
      buffer = buffer.slice(headerEnd + 4);
      continue;
    }
    const length = Number(match[1]);
    const total = headerEnd + 4 + length;
    if (buffer.length < total) break;
    const body = buffer.slice(headerEnd + 4, total).toString("utf8");
    buffer = buffer.slice(total);
    let msg;
    try {
      msg = JSON.parse(body);
    } catch {
      continue;
    }
    if (msg && msg.jsonrpc === "2.0" && msg.method) {
      onRequest(msg);
    }
  }
});
