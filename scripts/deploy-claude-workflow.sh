#!/usr/bin/env bash
set -euo pipefail

ORG="black-atom-industries"
WORKFLOW_TEMPLATE="templates/claude.yml"
TARGET_PATH=".github/workflows/claude.yml"
COMMIT_MSG="ci: add claude github action workflow"
BRANCH_NAME="ci/add-claude-action"
PR_TITLE="ci: add Claude GitHub Action workflow"
PR_BODY="Adds the Claude Code caller workflow that delegates to the shared reusable workflow in \`black-atom-industries/.github\`.

This enables \`@claude\` mentions in issues, PR comments, and PR reviews.

Part of black-atom-industries/.github#21"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

usage() {
  cat <<USAGE
Usage: $(basename "$0") [OPTIONS]

Deploy the Claude Code caller workflow to all repos in ${ORG}.

Options:
  --execute     Actually push changes (default is dry-run)
  --force       Overwrite existing claude.yml files
  --repo NAME   Target a single repo instead of all
  -h, --help    Show this help

Examples:
  $(basename "$0")                    # Dry-run all repos
  $(basename "$0") --execute          # Push to all repos
  $(basename "$0") --repo my-repo     # Dry-run single repo
  $(basename "$0") --repo my-repo --execute
USAGE
}

EXECUTE=false
FORCE=false
SINGLE_REPO=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --execute) EXECUTE=true; shift ;;
    --force) FORCE=true; shift ;;
    --repo) [[ $# -lt 2 ]] && echo -e "${RED}--repo requires a value${NC}" && exit 1; SINGLE_REPO="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo -e "${RED}Unknown option: $1${NC}"; usage; exit 1 ;;
  esac
done

template_file="${SCRIPT_DIR}/${WORKFLOW_TEMPLATE}"
if [[ ! -f "$template_file" ]]; then
  echo -e "${RED}Template not found: ${template_file}${NC}"
  exit 1
fi

if [[ "$EXECUTE" == "false" ]]; then
  echo -e "${CYAN}=== DRY RUN ===${NC} (pass --execute to push changes)"
  echo ""
fi

# Get repo list
if [[ -n "$SINGLE_REPO" ]]; then
  repos=("$SINGLE_REPO")
else
  repos=()
  while IFS= read -r name; do
    repos+=("$name")
  done < <(gh repo list "$ORG" --no-archived --json name -q '.[].name' --limit 200)
fi

skipped=0
would_deploy=0
deployed=0
errors=0

for repo in "${repos[@]}"; do
  # Skip the .github repo itself
  if [[ "$repo" == ".github" ]]; then
    echo -e "${YELLOW}SKIP${NC}  ${ORG}/${repo} (this is the shared workflow repo)"
    skipped=$((skipped + 1))
    continue
  fi

  # Check if file already exists
  if [[ "$FORCE" == "false" ]]; then
    if gh api "repos/${ORG}/${repo}/contents/${TARGET_PATH}" --silent 2>/dev/null; then
      echo -e "${YELLOW}SKIP${NC}  ${ORG}/${repo} (${TARGET_PATH} already exists, use --force to overwrite)"
      skipped=$((skipped + 1))
      continue
    fi
  fi

  if [[ "$EXECUTE" == "false" ]]; then
    echo -e "${GREEN}WOULD DEPLOY${NC}  ${ORG}/${repo}"
    would_deploy=$((would_deploy + 1))
  else
    # Get the default branch
    default_branch=$(gh repo view "${ORG}/${repo}" --json defaultBranchRef -q '.defaultBranchRef.name')

    # Get the latest commit SHA on the default branch
    base_sha=$(gh api "repos/${ORG}/${repo}/git/ref/heads/${default_branch}" --jq '.object.sha')

    # Create the branch
    if ! gh api "repos/${ORG}/${repo}/git/refs" \
      --method POST \
      --field ref="refs/heads/${BRANCH_NAME}" \
      --field sha="$base_sha" --silent 2>/dev/null; then
      echo -e "${YELLOW}SKIP${NC}  ${ORG}/${repo} (branch ${BRANCH_NAME} already exists — PR may be open)"
      skipped=$((skipped + 1))
      continue
    fi

    # Push the workflow file to the new branch
    content=$(base64 < "$template_file" | tr -d '\n')

    # Check if file exists on the branch (for updates with --force)
    sha=""
    if existing=$(gh api "repos/${ORG}/${repo}/contents/${TARGET_PATH}?ref=${BRANCH_NAME}" --jq '.sha' 2>/dev/null); then
      sha="$existing"
    fi

    json_payload=$(jq -n \
      --arg msg "$COMMIT_MSG" \
      --arg content "$content" \
      --arg branch "$BRANCH_NAME" \
      --arg sha "$sha" \
      '{
        message: $msg,
        content: $content,
        branch: $branch
      } + (if $sha != "" then {sha: $sha} else {} end)')

    if ! gh api "repos/${ORG}/${repo}/contents/${TARGET_PATH}" \
      --method PUT \
      --input - <<< "$json_payload" --silent 2>/dev/null; then
      echo -e "${RED}ERROR${NC}  ${ORG}/${repo} (failed to push file)"
      errors=$((errors + 1))
      continue
    fi

    # Create the PR
    if pr_url=$(gh pr create \
      --repo "${ORG}/${repo}" \
      --head "$BRANCH_NAME" \
      --base "$default_branch" \
      --title "$PR_TITLE" \
      --body "$PR_BODY" 2>/dev/null); then
      echo -e "${GREEN}PR CREATED${NC}  ${ORG}/${repo} -> ${pr_url}"
      deployed=$((deployed + 1))
    else
      echo -e "${RED}ERROR${NC}  ${ORG}/${repo} (branch pushed but PR creation failed)"
      errors=$((errors + 1))
    fi
  fi
done

echo ""
echo "--- Summary ---"
if [[ "$EXECUTE" == "false" ]]; then
  echo -e "Would deploy: ${GREEN}${would_deploy}${NC}"
  echo -e "Skipped:      ${YELLOW}${skipped}${NC}"
  echo ""
  echo -e "${CYAN}Run with --execute to push changes.${NC}"
else
  echo -e "PRs created: ${GREEN}${deployed}${NC}"
  echo -e "Skipped:  ${YELLOW}${skipped}${NC}"
  echo -e "Errors:   ${RED}${errors}${NC}"
fi
