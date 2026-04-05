---
name: org:audit-repo-meta
description: Audit and fix repo metadata (topics, labels, descriptions) across the Black Atom org
argument-hint: "[repo-name]  — audit a single repo, or omit for all"
---

# Audit Repo Metadata

Audit topics, labels, and descriptions across all Black Atom Industries repos. Flags issues, proposes fixes, applies after confirmation.

## What it checks

| Check | Source of truth | Fix |
|-|-|-|
| Category topic | `src/labels/config.ts` categories | `gh repo edit --add-topic` |
| Labels | `deno task sync-labels:dry` | `deno task sync-labels` |
| Description | Must be non-empty | `gh repo edit --description` |

## Commands reference

### Topics

```bash
# List repo topics
gh repo view black-atom-industries/<repo> --json repositoryTopics --jq '.repositoryTopics[].name'

# Add topic
gh repo edit black-atom-industries/<repo> --add-topic <category>

# Remove topic
gh repo edit black-atom-industries/<repo> --remove-topic <old-category>
```

### Description

```bash
# View current description
gh repo view black-atom-industries/<repo> --json description --jq '.description'

# Set description
gh repo edit black-atom-industries/<repo> --description "<text>"
```

### Labels

```bash
# Preview label changes
deno task sync-labels:dry -- <repo>

# Apply label changes
deno task sync-labels -- <repo>
```

## Steps

### 1. Discover repos

```bash
gh repo list black-atom-industries --json name,description,repositoryTopics --limit 100
```

If an argument was provided, filter to that repo only.

### 2. Audit each repo

For each repo, check:

1. **Topic** — does it have exactly one category topic from `src/labels/config.ts`? Flag if missing or ambiguous (multiple categories).
2. **Description** — is it non-empty? Flag if blank.
3. **Labels** — run `deno task sync-labels:dry -- <repo>` and check for CREATE/DELETE/UPDATE lines.

### 3. Report

Present findings as a table:

| Repo | Topic | Description | Labels |
|-|-|-|-|
| atlas | `black-atom-app` | ok | 2 to create |
| core | `black-atom-core` | ok | ok |
| some-repo | **missing** | **empty** | 3 to create |

### 4. Fix

After user confirms:

- **Topics**: `gh repo edit black-atom-industries/<repo> --add-topic <category>`
- **Descriptions**: `gh repo edit black-atom-industries/<repo> --description "<text>"` — propose description first, let user edit
- **Labels**: `deno task sync-labels -- <repo>`

Never auto-fix descriptions without showing the proposed text first.
