import { Plugin } from "@opencode/plugin"
import { applyOperation, type Input, type Json } from "./metadata"

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
          '"append" adds one object without replacing existing entries or other metadata keys;',
          'the stored entry gets an "at" timestamp (ISO) unless the value has one.',
          'Use "get" to read the metadata (all keys, or one key\'s array with "key").',
          'Use "remove" to delete the entries of "key" whose fields equal every field in "match".',
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
              enum: ["append", "get", "remove", "clear"],
              description:
                "append adds one entry and preserves all existing entries; get reads; remove deletes matching entries; clear removes ALL entries (only on explicit request).",
            },
            key: {
              type: "string",
              minLength: 1,
              description: "Top-level metadata key containing an array, such as abc. Required except for get.",
            },
            value: {
              type: "object",
              additionalProperties: true,
              description: "Exactly one JSON object to add to the array (required for append).",
            },
            match: {
              type: "object",
              additionalProperties: true,
              description: "Fields an entry must equal to be removed (required for remove), e.g. { \"id\": 123 }.",
            },
          },
          required: ["operation"],
          additionalProperties: false,
        },
        options: { codemode: false },
        execute: async (raw, toolContext) => {
          const input = raw as Input
          const sessionID = toolContext.sessionID
          const session = await ctx.session.get({ sessionID })
          const { metadata, result } = applyOperation({ ...(session.metadata ?? {}) } as Record<string, Json>, input, new Date())
          // Session.update replaces the metadata object; applyOperation preserves unrelated keys.
          if (input.operation !== "get") await ctx.session.update({ sessionID, metadata })
          return { content: JSON.stringify({ sessionID, operation: input.operation, result }) }
        },
      })
    })
  },
})
