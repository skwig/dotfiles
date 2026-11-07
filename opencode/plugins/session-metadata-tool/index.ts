import { Plugin } from "@opencode/plugin"

type Json = null | boolean | number | string | Json[] | { [key: string]: Json }
type JsonObject = { [key: string]: Json }
type Input = {
  operation: "append" | "clear"
  key: string
  value?: JsonObject
}

// Generic, session-scoped array tool: each metadata key managed by this tool
// contains an array of JSON objects. No plugin storage or Jira-specific logic.
export default Plugin.define({
  id: "session-metadata-tool",
  async setup(ctx) {
    await ctx.tool.transform((editor) => {
      editor.add({
        name: "session_metadata",
        description: [
          "Manage arrays of JSON objects in the current OpenCode session's native metadata.",
          'Use operation "append" when asked to add, set a NEW entry, attach, associate,',
          "store, or record session metadata (e.g. a PR, issue, or Jira ticket).",
          '"append" adds one object without replacing existing entries or other metadata keys.',
          'Use "clear" ONLY when explicitly asked to remove ALL entries from a metadata array.',
          '"clear" resets the chosen array to []; NEVER clear as preparation for append.',
          'Specify the top-level metadata key via "key" (e.g. "abc").',
          "This tool does not replace or edit individual existing entries.",
        ].join(" "),
        input: {
          type: "object",
          properties: {
            operation: {
              type: "string",
              enum: ["append", "clear"],
              description: "append adds one entry and preserves all existing entries; clear removes ALL entries (only on explicit request).",
            },
            key: {
              type: "string",
              minLength: 1,
              description: "Top-level metadata key containing an array, such as abc.",
            },
            value: {
              type: "object",
              additionalProperties: true,
              description: "Exactly one JSON object to add to the array (required for append; omit for clear).",
            },
          },
          required: ["operation", "key"],
          additionalProperties: false,
        },
        options: { codemode: false },
        execute: async (raw, toolContext) => {
          const input = raw as Input
          const key = input.key?.trim()
          if (!key) throw new Error("key must not be empty")
          if (["__proto__", "constructor", "prototype"].includes(key)) {
            throw new Error(`Unsafe metadata key: ${key}`)
          }

          const sessionID = toolContext.sessionID
          const session = await ctx.session.get({ sessionID })
          // Session.update replaces the metadata object, so preserve unrelated keys.
          const metadata = { ...(session.metadata ?? {}) } as Record<string, Json>
          let items: JsonObject[]

          if (input.operation === "clear") {
            // Also lets existing POC users replace an old non-array abc value.
            items = []
          } else if (input.operation === "append") {
            if (
              !Object.prototype.hasOwnProperty.call(input, "value") ||
              !input.value ||
              typeof input.value !== "object" ||
              Array.isArray(input.value)
            ) {
              throw new Error("append requires value to be a JSON object")
            }
            const current = metadata[key]
            if (current !== undefined && !Array.isArray(current)) {
              throw new Error(`metadata.${key} is not an array; use clear to reset it first`)
            }
            items = [...((current ?? []) as JsonObject[]), input.value]
          } else {
            throw new Error(`Unknown operation: ${String(input.operation)}`)
          }

          metadata[key] = items
          await ctx.session.update({ sessionID, metadata })
          return {
            content: JSON.stringify({ sessionID, operation: input.operation, key, count: items.length, value: items }),
          }
        },
      })
    })
  },
})
