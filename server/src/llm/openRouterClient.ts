export async function callOpenRouterJSON<T>(args: {
  model: string;
  system: string;
  user: unknown;
  temperature?: number;
  timeoutMs?: number;
}): Promise<T> {
  const apiKey = process.env.OPENROUTER_API_KEY;
  if (!apiKey || apiKey === "replace_on_server_only") {
    throw new Error("Missing OPENROUTER_API_KEY");
  }

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), args.timeoutMs ?? 12_000);

  try {
    const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
      method: "POST",
      signal: controller.signal,
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
        "X-Title": "OpenClaw"
      },
      body: JSON.stringify({
        model: args.model,
        temperature: args.temperature ?? 0.35,
        response_format: {
          type: "json_schema",
          json_schema: {
            name: "openclaw_pet_response",
            strict: true,
            schema: {
              type: "object",
              additionalProperties: true
            }
          }
        },
        messages: [
          { role: "system", content: args.system },
          { role: "user", content: JSON.stringify(args.user) }
        ]
      })
    });

    if (!response.ok) {
      throw new Error(`OpenRouter ${response.status}: ${await response.text()}`);
    }

    const json = await response.json();
    const content = json.choices?.[0]?.message?.content;
    if (!content) throw new Error("OpenRouter returned empty content");
    return JSON.parse(content) as T;
  } finally {
    clearTimeout(timeout);
  }
}
