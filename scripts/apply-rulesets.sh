#!/usr/bin/env bash
set -euo pipefail

# Apply Gitflow repository rulesets to a GitHub repository.
# Requires: gh CLI (authenticated)
#
# Usage:
#   ./scripts/apply-rulesets.sh                     # applies to current repo
#   ./scripts/apply-rulesets.sh owner/repo           # applies to specific repo
#   ./scripts/apply-rulesets.sh owner/repo --dry-run # preview without applying

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULESETS_DIR="$SCRIPT_DIR/../rulesets"

DRY_RUN=false
REPO=""

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --help|-h)
      echo "Usage: $(basename "$0") [owner/repo] [--dry-run]"
      echo ""
      echo "Apply Gitflow rulesets to a GitHub repository."
      echo ""
      echo "Arguments:"
      echo "  owner/repo   Target repository (default: current repo from gh)"
      echo "  --dry-run    Preview rulesets without applying"
      echo ""
      echo "Rulesets applied:"
      echo "  - main-branch.json      Protect main with PR rules and status checks"
      echo "  - develop-branch.json   Protect develop with PR rules and status checks"
      echo "  - release-branches.json Protect release/* branches (optional, prompted)"
      exit 0
      ;;
    *) REPO="$arg" ;;
  esac
done

# Check prerequisites
if ! command -v gh &>/dev/null; then
  echo -e "${RED}Error: 'gh' CLI is not installed. Install it from https://cli.github.com${NC}"
  exit 1
fi

if ! gh auth status &>/dev/null; then
  echo -e "${RED}Error: Not authenticated with GitHub. Run 'gh auth login' first.${NC}"
  exit 1
fi

if ! command -v jq &>/dev/null && ! command -v python3 &>/dev/null; then
  echo -e "${RED}Error: Either 'jq' or 'python3' is required to parse JSON. Install one of them.${NC}"
  exit 1
fi

# Resolve repository
if [[ -z "$REPO" ]]; then
  REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null || true)
  if [[ -z "$REPO" ]]; then
    echo -e "${RED}Error: Could not detect repository. Pass it as an argument: $(basename "$0") owner/repo${NC}"
    exit 1
  fi
fi

echo -e "${CYAN}Target repository: ${REPO}${NC}"
echo ""

# Check for existing rulesets to avoid duplicates
EXISTING=$(gh api "repos/${REPO}/rulesets" --jq '.[].name' 2>/dev/null || true)

apply_ruleset() {
  local file="$1"
  local name
  name=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['name'])" "$file" 2>/dev/null \
    || jq -r '.name' "$file")

  if echo "$EXISTING" | grep -qxF "$name"; then
    echo -e "${YELLOW}  Skipped:${NC} '$name' already exists"
    return
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${CYAN}  Would apply:${NC} $name"
    echo "    Source: $(basename "$file")"
    return
  fi

  if gh api "repos/${REPO}/rulesets" \
    --method POST \
    --input "$file" \
    --silent; then
    echo -e "${GREEN}  Applied:${NC} $name"
  else
    echo -e "${RED}  Failed:${NC} $name"
    return 1
  fi
}

# Apply main and develop rulesets
echo "Applying rulesets..."
echo ""

ERRORS=0

for ruleset in main-branch.json develop-branch.json; do
  file="$RULESETS_DIR/$ruleset"
  if [[ ! -f "$file" ]]; then
    echo -e "${RED}  Missing: $file${NC}"
    ERRORS=$((ERRORS + 1))
    continue
  fi
  apply_ruleset "$file" || ERRORS=$((ERRORS + 1))
done

# Prompt for optional release branches ruleset
RELEASE_FILE="$RULESETS_DIR/release-branches.json"
if [[ -f "$RELEASE_FILE" ]]; then
  echo ""
  read -rp "Apply release branch protection? (recommended) [Y/n]: " APPLY_RELEASE
  APPLY_RELEASE="${APPLY_RELEASE:-Y}"
  if [[ "$APPLY_RELEASE" =~ ^[Yy]$ ]]; then
    apply_ruleset "$RELEASE_FILE" || ERRORS=$((ERRORS + 1))
  else
    echo -e "${YELLOW}  Skipped:${NC} release branches ruleset"
  fi
fi

echo ""
if [[ "$DRY_RUN" == "true" ]]; then
  echo -e "${CYAN}Dry run complete. No changes were made.${NC}"
elif [[ "$ERRORS" -eq 0 ]]; then
  echo -e "${GREEN}All rulesets applied successfully.${NC}"
  echo ""
  echo "View rulesets at: https://github.com/${REPO}/settings/rules"
else
  echo -e "${YELLOW}Completed with ${ERRORS} error(s). Check the output above.${NC}"
  exit 1
fi
