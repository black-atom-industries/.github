import { assertEquals, assertRejects } from "@std/assert";
import { gh, GhError, ghJson } from "./mod.ts";

Deno.test("gh() returns stdout from a successful command", async () => {
    const output = await gh(["--version"]);
    assertEquals(output.startsWith("gh version"), true);
});

Deno.test("gh() throws GhError on non-zero exit", async () => {
    await assertRejects(
        () => gh(["issue", "view", "999999", "--repo", "black-atom-industries/.github"]),
        GhError,
    );
});

Deno.test("ghJson() parses JSON output", async () => {
    const repos = await ghJson<{ name: string }[]>([
        "repo",
        "list",
        "black-atom-industries",
        "--json",
        "name",
        "--limit",
        "1",
    ]);
    assertEquals(Array.isArray(repos), true);
    assertEquals(repos.length, 1);
    assertEquals(typeof repos[0].name, "string");
});

Deno.test("ghJson() throws on non-JSON output", async () => {
    await assertRejects(
        () => ghJson(["--version"]),
        SyntaxError,
    );
});
