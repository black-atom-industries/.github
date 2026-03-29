#!/usr/bin/env bash
set -euo pipefail

ORG="black-atom-industries"
BRANCH_NAME="ci/cleanup-old-claude-workflows"
COMMIT_MSG="ci: remove old claude workflow file"
PR_TITLE="ci: remove old Claude workflow files"
PR_BODY="Removes old/beta Claude workflow files that have been replaced by the shared reusable workflow in \`black-atom-industries/.github\`.

Part of black-atom-industries/.github#21"

# Known old/beta workflow filenames to look for
OLD_FILES=(
  ".github/workflows/claude-pr.yml"
  ".github/workflows/claude-issue.yml"
  ".github/workflows/claude-review.yml"
  ".github/workflows/claude-bot.yml"
)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

usage() {
  cat <<USAGE
Usage: $(basename "$0") [OPTIONS]

Detect and optionally remove old/beta Claude workflow files across ${ORG} repos.
Creates a branch and PR per repo when deleting.

Options:
  --delete      Create PRs to remove found files (default is scan-only)
  --repo NAME   Target a single repo instead of all
  -h, --help    Show this help

Examples:
  $(basename "$0")                    # Scan all repos for old files
  $(basename "$0") --delete           # Create PRs to remove old files
  $(basename "$0") --repo my-repo     # Scan a single repo
USAGE
}

DELETE=false
SINGLE_REPO=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --delete) DELETE=true; shift ;;
    --repo) [[ $# -lt 2 ]] && echo -e "${RED}--repo requires a value${NC}" && exit 1; SINGLE_REPO="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo -e "${RED}Unknown option: $1${NC}"; usage; exit 1 ;;
  esac
done

if [[ "$DELETE" == "false" ]]; then
  echo -e "${CYAN}=== SCAN MODE ===${NC} (pass --delete to create PRs for removal)"
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

found_total=0
prs_created=0
errors=0

for repo in "${repos[@]}"; do
  # Collect old files found in this repo
  found_in_repo=()
  shas_in_repo=()

  for file in "${OLD_FILES[@]}"; do
    if file_sha=$(gh api "repos/${ORG}/${repo}/contents/${file}" --jq '.sha' 2>/dev/null); then
      found_in_repo+=("$file")
      shas_in_repo+=("$file_sha")
      found_total=$((found_total + 1))
      echo -e "${YELLOW}FOUND${NC}  ${ORG}/${repo} -> ${file}"
    fi
  done

  # Skip if nothing found in this repo
  [[ ${#found_in_repo[@]} -eq 0 ]] && continue

  if [[ "$DELETE" == "true" ]]; then
    # Get the default branch
    default_branch=$(gh repo view "${ORG}/${repo}" --json defaultBranchRef -q '.defaultBranchRef.name')

    # Create the branch from default
    base_sha=$(gh api "repos/${ORG}/${repo}/git/ref/heads/${default_branch}" --jq '.object.sha')

    if ! gh api "repos/${ORG}/${repo}/git/refs" \
      --method POST \
      --field ref="refs/heads/${BRANCH_NAME}" \
      --field sha="$base_sha" --silent 2>/dev/null; then
      echo -e "${YELLOW}SKIP${NC}  ${ORG}/${repo} (branch ${BRANCH_NAME} already exists — PR may be open)"
      continue
    fi

    # Delete each old file on the branch
    delete_ok=true
    for i in "${!found_in_repo[@]}"; do
      file="${found_in_repo[$i]}"
      sha="${shas_in_repo[$i]}"

      if ! gh api "repos/${ORG}/${repo}/contents/${file}" \
        --method DELETE \
        -f message="${COMMIT_MSG}" \
        -f sha="$sha" \
        -f branch="$BRANCH_NAME" --silent 2>/dev/null; then
        echo -e "${RED}ERROR${NC}  ${ORG}/${repo} -> ${file} (failed to delete on branch)"
        delete_ok=false
        errors=$((errors + 1))
      fi
    done

    # Create PR if at least one file was deleted
    if [[ "$delete_ok" == "true" ]]; then
      if pr_url=$(gh pr create \
        --repo "${ORG}/${repo}" \
        --head "$BRANCH_NAME" \
        --base "$default_branch" \
        --title "$PR_TITLE" \
        --body "$PR_BODY" 2>/dev/null); then
        echo -e "${GREEN}PR CREATED${NC}  ${ORG}/${repo} -> ${pr_url}"
        prs_created=$((prs_created + 1))
      else
        echo -e "${RED}ERROR${NC}  ${ORG}/${repo} (files deleted on branch but PR creation failed)"
        errors=$((errors + 1))
      fi
    fi
  fi
done

echo ""
if [[ $found_total -eq 0 ]]; then
  echo -e "${GREEN}No old Claude workflow files found.${NC}"
else
  echo -e "Found: ${YELLOW}${found_total}${NC} old file(s)"
  if [[ "$DELETE" == "true" ]]; then
    echo -e "PRs created: ${GREEN}${prs_created}${NC}"
    echo -e "Errors:      ${RED}${errors}${NC}"
  else
    echo -e "${CYAN}Run with --delete to create PRs for removal.${NC}"
  fi
fi
