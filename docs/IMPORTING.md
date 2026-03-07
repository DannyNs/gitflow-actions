# Importing Gitflow Actions Into Your Repository

Three methods are available depending on your needs.

## Method 1: Copy Files (Simplest)

Copy the workflow files directly into your repository:

```bash
# Clone this repository
git clone https://github.com/YOUR_ORG/gitflow-actions.git /tmp/gitflow-actions

# Copy workflows into your project
cp -r /tmp/gitflow-actions/.github/workflows/ YOUR_PROJECT/.github/workflows/

# Optionally copy the init script
cp -r /tmp/gitflow-actions/scripts/ YOUR_PROJECT/scripts/

# Clean up
rm -rf /tmp/gitflow-actions
```

Then commit the new files to your repository.

**Pros:** Full control, no external dependencies, easy to customize.
**Cons:** Won't receive upstream updates automatically.

## Method 2: Reusable Workflows

Reference the workflows from this repository without copying them. Create thin caller workflows in your repo.

### Example: `.github/workflows/pr-validation.yml`

```yaml
name: PR Validation

on:
  pull_request:
    types: [opened, edited, reopened, synchronize]
    branches: [main, develop, 'release/**']

jobs:
  validate:
    uses: YOUR_ORG/gitflow-actions/.github/workflows/pr-validation.yml@v1
```

### Example: `.github/workflows/release.yml`

```yaml
name: Release Workflow

on:
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches: [main]

jobs:
  release:
    uses: YOUR_ORG/gitflow-actions/.github/workflows/release.yml@v1
    secrets: inherit
```

### Example: `.github/workflows/feature.yml`

```yaml
name: Feature CI

on:
  pull_request:
    types: [opened, synchronize, reopened]
    branches: [develop]

jobs:
  feature:
    uses: YOUR_ORG/gitflow-actions/.github/workflows/feature.yml@v1
```

Repeat this pattern for each workflow you want to use. Pin to a tag (`@v1`) or commit SHA for stability.

**Pros:** Centralized updates, minimal boilerplate in each repo.
**Cons:** Requires the source repo to be accessible (public or within the same org). Harder to customize per-repo.

## Method 3: Organization Template Repository

Set up this repository as a GitHub template so new repos get Gitflow workflows automatically.

1. Go to **Settings > General** for this repository
2. Check **Template repository**
3. When creating new repos, select this as the template

For organization-wide workflow templates:

1. Create a `.github` repository in your organization (if it doesn't exist)
2. Create a `workflow-templates/` directory
3. For each workflow, add:
   - The workflow file (e.g., `gitflow-pr-validation.yml`)
   - A properties file (e.g., `gitflow-pr-validation.properties.json`)

### Example properties file:

```json
{
  "name": "Gitflow PR Validation",
  "description": "Enforce Gitflow PR routing rules",
  "iconName": "git-branch",
  "categories": ["Automation"]
}
```

Organization members will see these templates under **Actions > New workflow** in their repos.

**Pros:** Seamless onboarding for new repositories.
**Cons:** Existing repos need manual setup. Templates are copied at creation time (no auto-updates).

## After Importing

1. **Initialize Gitflow:** Run the init workflow or `scripts/init-gitflow.sh` to create the `develop` branch
2. **Apply branch rulesets:** Run `./scripts/apply-rulesets.sh` to configure branch protection automatically (or follow [BRANCH-RULES.md](BRANCH-RULES.md) for manual setup)
3. **Customize CI:** Edit `feature.yml` to add your build/test/lint steps
