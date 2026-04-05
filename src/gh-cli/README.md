# gh CLI Reference

Typed wrapper around the GitHub CLI (`gh`) for Black Atom Industries org tooling.

## Wrapper API

```ts
import { gh, ghJson } from "./mod.ts";

// Raw string output
const version = await gh(["--version"]);

// Typed JSON output
const repos = await ghJson<{ name: string }[]>([
    "repo",
    "list",
    "black-atom-industries",
    "--json",
    "name",
]);
```

Both functions throw `GhError` on non-zero exit codes.

## Key Commands

### Repo Discovery

```bash
# List all org repos
gh repo list black-atom-industries --json name --jq '.[].name' --limit 100

# Get repo topics (used for category detection)
gh repo view black-atom-industries/core --json repositoryTopics \
  --jq '[.repositoryTopics[].name] | join(", ")'

# List repos by category topic
gh repo list black-atom-industries --topic black-atom-adapter --json name --jq '.[].name'
```

### Repo Topics

```bash
# Add a topic
gh repo edit black-atom-industries/core --add-topic black-atom-core

# Remove a topic
gh repo edit black-atom-industries/core --remove-topic old-topic
```

**BAI categories**: `black-atom-core`, `black-atom-adapter`, `black-atom-app`, `black-atom-tool`, `black-atom-plugin`, `black-atom-meta`, `black-atom-web`

### Labels

```bash
# List labels (JSON)
gh label list --repo black-atom-industries/core --json name,color,description --limit 100

# Create
gh label create "state:blocked" --repo black-atom-industries/core --color E11D21 --description "Blocked"

# Update
gh label edit "state:blocked" --repo black-atom-industries/core --color E11D21 --description "New desc"

# Delete
gh label delete "old-label" --repo black-atom-industries/core --yes
```

### Issues

```bash
# List open issues assigned to me
gh search issues --assignee=@me --owner=black-atom-industries --state=open \
  --json repository,number,title,labels,url

# View issue details
gh issue view 20 --repo black-atom-industries/.github --json title,body,labels,state

# Create issue
gh issue create --repo black-atom-industries/core --title "Title" --body "Body"

# Edit issue (add label)
gh issue edit 20 --repo black-atom-industries/.github --add-label "state:blocked"

# Close issue
gh issue close 20 --repo black-atom-industries/.github
```

### GraphQL via `gh api`

```bash
# List issue types
gh api graphql -f query='{ organization(login: "black-atom-industries") {
  issueTypes(first: 20) { nodes { id name } }
}}' --jq '.data.organization.issueTypes.nodes[] | "\(.name) | \(.id)"'

# List project fields and options
gh api graphql -f query='{ organization(login: "black-atom-industries") {
  projectV2(number: 7) { fields(first: 20) { nodes {
    ... on ProjectV2SingleSelectField { id name options { id name } }
  }}}
}}' --jq '.data.organization.projectV2.fields.nodes[] | select(.name != null)'

# Add blocker relationship
BLOCKED_ID=$(gh issue view 20 --repo black-atom-industries/.github --json id --jq '.id')
BLOCKING_ID=$(gh issue view 10 --repo black-atom-industries/core --json id --jq '.id')
gh api graphql -f query="mutation {
  addBlockedBy(input: { issueId: \"$BLOCKED_ID\", blockingIssueId: \"$BLOCKING_ID\" }) {
    issue { title } blockingIssue { title }
  }
}"

# Add sub-issue
PARENT_ID=$(gh issue view 5 --repo black-atom-industries/.github --json id --jq '.id')
SUB_ID=$(gh issue view 20 --repo black-atom-industries/.github --json id --jq '.id')
gh api graphql -f query="mutation {
  addSubIssue(input: { issueId: \"$PARENT_ID\", subIssueId: \"$SUB_ID\" }) {
    issue { title } subIssue { title }
  }
}"

# Query blocked issues
gh api graphql -f query='{ repository(owner: "black-atom-industries", name: "core") {
  issues(first: 50, states: OPEN) { nodes {
    number title
    blockedBy(first: 5) { nodes { number title } }
  }}
}}' --jq '.data.repository.issues.nodes[] | select(.blockedBy.nodes | length > 0)'
```

### Project Board

```bash
# List project items with status and priority
gh project item-list 7 --owner black-atom-industries --format json
```

**Project**: "Black Atom V1" (#7)
