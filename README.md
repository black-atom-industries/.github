# .github

Org-level configuration for Black Atom Industries: issue templates, label management, and shared tooling.

## What's here

```
.github/ISSUE_TEMPLATE/   # Org-wide issue templates (Feature, Bug)
src/labels/               # Label sync tooling (config, sync, types)
src/gh-cli/               # Thin Deno wrapper around `gh` CLI
.githooks/                # Pre-commit hook (runs checks)
```

## Label sync

Synchronizes GitHub labels across all org repos. Each repo is categorized by its GitHub topic (e.g. `black-atom-core`, `black-atom-adapter`) and gets org-wide labels plus category-specific topic labels.

```bash
# Preview what would change
deno task sync-labels:dry

# Apply changes
deno task sync-labels

# Sync a specific repo
deno task sync-labels -- core livery
```

### How categorization works

Repos are discovered via `gh repo list` and categorized by their GitHub repository topic:

| Topic                | Repos            | Topic labels                          |
| -------------------- | ---------------- | ------------------------------------- |
| `black-atom-core`    | core             | cli, themes, tokens, templates, build |
| `black-atom-adapter` | nvim, zed, etc.  | tokens, templates                     |
| `black-atom-app`     | atlas, helm      | cli, ui                               |
| `black-atom-tool`    | livery, shiplog  | cli, config                           |
| `black-atom-plugin`  | radar.nvim, etc. | _(none)_                              |
| `black-atom-meta`    | .github          | ci                                    |
| `black-atom-web`     | website, ui      | components, content, design           |

Repos without a recognized topic get org-wide labels applied and a warning with instructions to add a category.

All repos also get the 5 org-wide labels: `state:needs-review`, `state:blocked`, `state:reviewed`, `contrib:good-first-issue`, `contrib:help-wanted`.

Labels matching `protectedLabels` in config (e.g. `autorelease: *`) are never deleted.

## Setup

```bash
# Install Deno dependencies
deno install

# Set up pre-commit hooks
deno task install-hooks
```

## Available tasks

| Task                        | Description                          |
| --------------------------- | ------------------------------------ |
| `deno task checks`          | Run fmt, lint, type-check, and tests |
| `deno task sync-labels`     | Sync labels across org repos         |
| `deno task sync-labels:dry` | Preview label changes (no writes)    |
| `deno task install-hooks`   | Configure git to use `.githooks/`    |
