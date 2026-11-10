import { describe, expect, test } from "bun:test"
import { applyOperation } from "./metadata"

const now = new Date("2026-11-10T12:00:00.000Z")
const base = () => ({
  github: [
    { owner: "octo-org", repo: "hello-world", pr: 42 },
    { owner: "octo-org", repo: "hello-world", pr: 43 },
  ],
  other: [{ a: 1 }],
})

describe("append", () => {
  test("stamps at and keeps other keys", () => {
    const { metadata, result } = applyOperation(base(), { operation: "append", key: "stage", value: { stage: "implementing" } }, now)
    expect(metadata.stage).toEqual([{ stage: "implementing", at: "2026-11-10T12:00:00.000Z" }])
    expect(metadata.github).toEqual(base().github)
    expect(metadata.other).toEqual(base().other)
    expect(result).toMatchObject({ key: "stage", count: 1 })
  })

  test("keeps a given at", () => {
    const { metadata } = applyOperation({}, { operation: "append", key: "stage", value: { stage: "x", at: "earlier" } }, now)
    expect(metadata.stage).toEqual([{ stage: "x", at: "earlier" }])
  })

  test("appends after existing entries", () => {
    const { metadata } = applyOperation(base(), { operation: "append", key: "other", value: { b: 2 } }, now)
    expect(metadata.other).toEqual([{ a: 1 }, { b: 2, at: "2026-11-10T12:00:00.000Z" }])
  })

  test("rejects a non-array key and a non-object value", () => {
    expect(() => applyOperation({ x: "text" }, { operation: "append", key: "x", value: { a: 1 } }, now)).toThrow()
    expect(() => applyOperation({}, { operation: "append", key: "x" }, now)).toThrow()
    expect(() => applyOperation({}, { operation: "append", key: "x", value: [] as any }, now)).toThrow()
  })
})

describe("clear", () => {
  test("resets the key to an empty array", () => {
    const { metadata } = applyOperation(base(), { operation: "clear", key: "github" }, now)
    expect(metadata.github).toEqual([])
    expect(metadata.other).toEqual(base().other)
  })
})

describe("get", () => {
  test("whole metadata without a key", () => {
    const { metadata, result } = applyOperation(base(), { operation: "get" }, now)
    expect(result).toEqual(base())
    expect(metadata).toEqual(base())
  })

  test("one key's array, missing key is empty", () => {
    expect(applyOperation(base(), { operation: "get", key: "other" }, now).result).toEqual([{ a: 1 }])
    expect(applyOperation(base(), { operation: "get", key: "missing" }, now).result).toEqual([])
  })
})

describe("remove", () => {
  test("removes only entries matching every field", () => {
    const { metadata, result } = applyOperation(base(), { operation: "remove", key: "github", match: { pr: 42 } }, now)
    expect(metadata.github).toEqual([base().github[1]])
    expect(result).toMatchObject({ removed: 1 })
  })

  test("no match removes nothing", () => {
    const { metadata, result } = applyOperation(base(), { operation: "remove", key: "github", match: { pr: 1, repo: "hello-world" } }, now)
    expect(metadata.github).toEqual(base().github)
    expect(result).toMatchObject({ removed: 0 })
  })

  test("requires a non-empty match", () => {
    expect(() => applyOperation(base(), { operation: "remove", key: "github" }, now)).toThrow()
    expect(() => applyOperation(base(), { operation: "remove", key: "github", match: {} }, now)).toThrow()
  })
})

test("unsafe or empty keys are rejected", () => {
  for (const key of ["__proto__", "constructor", "prototype", " "]) {
    expect(() => applyOperation({}, { operation: "append", key, value: { a: 1 } }, now)).toThrow()
    expect(() => applyOperation({}, { operation: "get", key }, now)).toThrow()
  }
  expect(() => applyOperation({}, { operation: "clear" }, now)).toThrow()
})
