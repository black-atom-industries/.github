import { bold, dim, green, red, yellow } from "@std/fmt/colors";
import { gh, ghJson } from "../gh-cli/mod.ts";
import { config } from "./config.ts";
import type { Label } from "./types.ts";

interface RepoTopic {
    name: string;
}

interface CurrentLabel {
    name: string;
    color: string;
    description: string;
}

function parseArgs(args: string[]): { dryRun: boolean; repos: string[] } {
    const dryRun = args.includes("--dry-run");
    const repos = args.filter((a) => !a.startsWith("--"));
    return { dryRun, repos };
}

async function discoverRepos(): Promise<string[]> {
    const repos = await ghJson<{ name: string }[]>([
        "repo",
        "list",
        config.org,
        "--json",
        "name",
        "--limit",
        "100",
    ]);
    return repos.map((r) => r.name);
}

async function getCategoryForRepo(repo: string): Promise<string | null> {
    const result = await ghJson<{ repositoryTopics: RepoTopic[] }>([
        "repo",
        "view",
        `${config.org}/${repo}`,
        "--json",
        "repositoryTopics",
    ]);

    const topicNames = (result.repositoryTopics ?? []).map((t) => t.name);
    const categoryKeys = Object.keys(config.categories);

    for (const category of categoryKeys) {
        if (topicNames.includes(category)) {
            return category;
        }
    }

    return null;
}

function getDesiredLabels(category: string | null): Label[] {
    const topicLabels = category ? config.categories[category]?.topicLabels ?? [] : [];
    return [...config.orgWideLabels, ...topicLabels];
}

function isProtected(labelName: string): boolean {
    return config.protectedLabels.includes(labelName);
}

function colorsMatch(a: string, b: string): boolean {
    return a.toLowerCase() === b.toLowerCase();
}

async function runOrDry(dryRun: boolean, args: string[]): Promise<void> {
    if (dryRun) {
        console.log(`  ${dim("[dry-run]")} gh ${args.join(" ")}`);
    } else {
        await gh(args);
    }
}

async function syncRepo(repo: string, dryRun: boolean): Promise<void> {
    console.log(`\n${bold(`=== ${config.org}/${repo} ===`)}`);

    const category = await getCategoryForRepo(repo);
    if (!category) {
        const knownCategories = Object.keys(config.categories).join(", ");
        console.log(
            `  ${yellow("WARN: uncategorized repo — org-wide labels only, no topic labels")}`,
        );
        console.log(
            `  ${yellow("ACTION: add a GitHub topic to this repo or a new category to config.ts")}`,
        );
        console.log(`  ${dim(`Known categories: ${knownCategories}`)}`);
    } else {
        console.log(`  ${dim(`Category: ${category}`)}`);
    }

    const currentLabels = await ghJson<CurrentLabel[]>([
        "label",
        "list",
        "--repo",
        `${config.org}/${repo}`,
        "--json",
        "name,color,description",
        "--limit",
        "100",
    ]);

    const desiredLabels = getDesiredLabels(category);
    const desiredNames = new Set(desiredLabels.map((l) => l.name));

    // Delete labels not in desired set (unless protected). An unrecognized topic may come from a
    // stale config, so an uncategorized repo keeps its other labels.
    for (const label of currentLabels) {
        if (isProtected(label.name)) {
            console.log(`  ${dim(`KEEP (protected): ${label.name}`)}`);
            continue;
        }
        if (!desiredNames.has(label.name) && !category) {
            console.log(`  ${dim(`KEEP (uncategorized repo): ${label.name}`)}`);
            continue;
        }
        if (!desiredNames.has(label.name)) {
            console.log(`  ${red(`DELETE: ${label.name}`)}`);
            await runOrDry(dryRun, [
                "label",
                "delete",
                label.name,
                "--repo",
                `${config.org}/${repo}`,
                "--yes",
            ]);
        }
    }

    // Create or update desired labels
    const currentByName = new Map(currentLabels.map((l) => [l.name, l]));

    for (const desired of desiredLabels) {
        const existing = currentByName.get(desired.name);

        if (!existing) {
            console.log(`  ${green(`CREATE: ${desired.name} (#${desired.color})`)}`);
            await runOrDry(dryRun, [
                "label",
                "create",
                desired.name,
                "--repo",
                `${config.org}/${repo}`,
                "--color",
                desired.color,
                "--description",
                desired.description,
            ]);
        } else if (
            !colorsMatch(existing.color, desired.color) ||
            existing.description !== desired.description
        ) {
            console.log(`  ${yellow(`UPDATE: ${desired.name} (#${desired.color})`)}`);
            await runOrDry(dryRun, [
                "label",
                "edit",
                desired.name,
                "--repo",
                `${config.org}/${repo}`,
                "--color",
                desired.color,
                "--description",
                desired.description,
            ]);
        } else {
            console.log(`  ${dim(`OK: ${desired.name}`)}`);
        }
    }
}

if (import.meta.main) {
    const { dryRun, repos: repoFilter } = parseArgs(Deno.args);

    if (dryRun) {
        console.log(bold("*** DRY RUN — no changes will be made ***"));
    }

    const repos = repoFilter.length > 0 ? repoFilter : await discoverRepos();
    console.log(`Syncing labels for ${repos.length} repos...`);

    const failed: string[] = [];
    for (const repo of repos) {
        try {
            await syncRepo(repo, dryRun);
        } catch (err) {
            console.log(`  ${red(`ERROR: ${err instanceof Error ? err.message : err}`)}`);
            failed.push(repo);
        }
    }

    if (failed.length > 0) {
        console.log(`\n${red(`Failed repos (${failed.length}):`)}`);
        for (const repo of failed) {
            console.log(`  - ${repo}`);
        }
        Deno.exit(1);
    }

    console.log("\nDone.");
}
