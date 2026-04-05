/**
 * Thin wrapper around the `gh` CLI using Deno.Command.
 * All GitHub API interactions in this repo go through these functions.
 */

export class GhError extends Error {
    constructor(
        public readonly args: string[],
        public readonly stderr: string,
        public readonly exitCode: number,
    ) {
        super(`gh ${args.join(" ")} failed (exit ${exitCode}): ${stderr.trim()}`);
        this.name = "GhError";
    }
}

/**
 * Run a `gh` command and return stdout as a string.
 * Throws `GhError` on non-zero exit.
 */
export async function gh(args: string[]): Promise<string> {
    const command = new Deno.Command("gh", {
        args,
        stdout: "piped",
        stderr: "piped",
    });

    const { code, stdout, stderr } = await command.output();
    const out = new TextDecoder().decode(stdout);
    const err = new TextDecoder().decode(stderr);

    if (code !== 0) {
        throw new GhError(args, err, code);
    }

    return out.trim();
}

/**
 * Run a `gh` command and parse stdout as JSON.
 * Throws `GhError` on non-zero exit or if output isn't valid JSON.
 */
export async function ghJson<T>(args: string[]): Promise<T> {
    const output = await gh(args);
    return JSON.parse(output) as T;
}
