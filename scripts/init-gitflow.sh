#!/usr/bin/env bash
set -euo pipefail

# Initialize Gitflow branching model in the current repository.
# Creates the 'develop' branch from 'main' if it doesn't already exist.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo -e "${RED}Error: Not inside a git repository.${NC}"
  exit 1
fi

if ! git rev-parse --verify main &>/dev/null; then
  echo -e "${RED}Error: 'main' branch does not exist. Create it first.${NC}"
  exit 1
fi

if git rev-parse --verify develop &>/dev/null; then
  echo -e "${YELLOW}Branch 'develop' already exists. Nothing to do.${NC}"
  exit 0
fi

echo -e "${GREEN}Creating 'develop' branch from 'main'...${NC}"
git branch develop main

if git remote get-url origin &>/dev/null; then
  echo -e "${GREEN}Pushing 'develop' to origin...${NC}"
  git push -u origin develop
fi

echo -e "${GREEN}Gitflow initialized successfully.${NC}"
echo ""
echo "Next steps:"
echo "  1. Set up branch protection rules (see docs/BRANCH-RULES.md)"
echo "  2. Start working with feature branches: git checkout -b feature/my-feature develop"
