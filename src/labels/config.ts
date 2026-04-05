import type { LabelConfig } from "./types.ts";

export const config: LabelConfig = {
    org: "black-atom-industries",

    orgWideLabels: [
        { name: "state:needs-review", color: "FBCA04", description: "Awaiting review" },
        {
            name: "state:blocked",
            color: "E11D21",
            description: "Blocked by an external dependency or constraint",
        },
        { name: "state:reviewed", color: "0E8A16", description: "Review completed" },
        { name: "contrib:good-first-issue", color: "7057FF", description: "Good for newcomers" },
        {
            name: "contrib:help-wanted",
            color: "008672",
            description: "Open for external contributions",
        },
    ],

    protectedLabels: ["autorelease: pending", "autorelease: tagged"],

    categories: {
        "black-atom-core": {
            topicLabels: [
                { name: "topic:cli", color: "0075CA", description: "CLI tooling" },
                { name: "topic:themes", color: "0075CA", description: "Theme definitions" },
                { name: "topic:tokens", color: "0075CA", description: "Design tokens" },
                { name: "topic:templates", color: "0075CA", description: "Eta templates" },
                { name: "topic:build", color: "0075CA", description: "Build system" },
            ],
        },
        "black-atom-adapter": {
            topicLabels: [
                { name: "topic:tokens", color: "0075CA", description: "Design tokens" },
                { name: "topic:templates", color: "0075CA", description: "Config templates" },
            ],
        },
        "black-atom-app": {
            topicLabels: [
                { name: "topic:cli", color: "0075CA", description: "CLI tooling" },
                { name: "topic:ui", color: "0075CA", description: "User interface" },
            ],
        },
        "black-atom-tool": {
            topicLabels: [
                { name: "topic:cli", color: "0075CA", description: "CLI tooling" },
                { name: "topic:config", color: "0075CA", description: "Configuration" },
            ],
        },
        "black-atom-plugin": {
            topicLabels: [],
        },
        "black-atom-meta": {
            topicLabels: [
                { name: "topic:ci", color: "0075CA", description: "CI/CD and GitHub Actions" },
            ],
        },
        "black-atom-web": {
            topicLabels: [
                { name: "topic:components", color: "0075CA", description: "UI components" },
                { name: "topic:content", color: "0075CA", description: "Site content" },
                { name: "topic:design", color: "0075CA", description: "Visual design" },
            ],
        },
    },
};
