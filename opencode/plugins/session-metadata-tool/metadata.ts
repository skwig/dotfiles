export type Json = null | boolean | number | string | Json[] | { [key: string]: Json }
export type JsonObject = { [key: string]: Json }
export type Input = {
  operation: "append" | "clear" | "get" | "remove"
  key?: string
  value?: JsonObject
  match?: JsonObject
}

const isObject = (value: unknown): value is JsonObject => !!value && typeof value === "object" && !Array.isArray(value)

const keyOf = (input: Input): string => {
  const key = input.key?.trim()
  if (!key) throw new Error("key must not be empty")
  if (["__proto__", "constructor", "prototype"].includes(key)) throw new Error(`Unsafe metadata key: ${key}`)
  return key
}

const arrayAt = (metadata: Record<string, Json>, key: string, hint: string): JsonObject[] => {
  const current = metadata[key]
  if (current !== undefined && !Array.isArray(current)) throw new Error(`metadata.${key} is not an array; ${hint}`)
  return (current ?? []) as JsonObject[]
}

const matches = (entry: JsonObject, match: JsonObject) =>
  Object.entries(match).every(([field, expected]) => JSON.stringify(entry?.[field]) === JSON.stringify(expected))

// Each key managed by the tool holds an array of JSON objects. Returns the new metadata (other keys preserved) and
// the tool result; `get` returns the metadata unchanged.
export function applyOperation(
  metadata: Record<string, Json>,
  input: Input,
  now: Date,
): { metadata: Record<string, Json>; result: Json } {
  if (input.operation === "get") {
    if (input.key === undefined) return { metadata, result: metadata }
    const key = keyOf(input)
    return { metadata, result: arrayAt(metadata, key, "it was not written by this tool") }
  }

  const key = keyOf(input)
  const next = { ...metadata }
  if (input.operation === "clear") {
    next[key] = []
    return { metadata: next, result: { key, count: 0 } }
  }
  if (input.operation === "append") {
    if (!isObject(input.value)) throw new Error("append requires value to be a JSON object")
    const entry = "at" in input.value ? input.value : { ...input.value, at: now.toISOString() }
    const items = [...arrayAt(metadata, key, "use clear to reset it first"), entry]
    next[key] = items
    return { metadata: next, result: { key, count: items.length, value: items } }
  }
  if (input.operation === "remove") {
    if (!isObject(input.match) || Object.keys(input.match).length === 0) throw new Error("remove requires a non-empty match object")
    const current = arrayAt(metadata, key, "nothing to remove")
    const kept = current.filter((entry) => !matches(entry, input.match!))
    next[key] = kept
    return { metadata: next, result: { key, removed: current.length - kept.length, count: kept.length } }
  }
  throw new Error(`Unknown operation: ${String(input.operation)}`)
}
