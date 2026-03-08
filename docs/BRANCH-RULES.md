# Branch Protection Rules

Recommended GitHub branch protection settings to enforce Gitflow.

## Quick Setup with Rulesets (Recommended)

Ready-to-import ruleset JSON files are included in the `rulesets/` directory. Apply them all at once:

```bash
# Apply to the current repository
./scripts/apply-rulesets.sh

# Apply to a specific repository
./scripts/apply-rulesets.sh owner/repo

# Preview without applying
./scripts/apply-rulesets.sh owner/repo --dry-run
```

This creates three rulesets matching the manual configuration described below. You can also import them manually via **Settings > Rules > Rulesets > New ruleset > Import a ruleset**.

---

## Manual Setup

If you prefer to configure rules manually (or use legacy branch protection instead of rulesets):

### `main` Branch

Go to **Settings > Branches > Add rule** and configure:

- **Branch name pattern:** `main`
- **Require a pull request before merging:** Yes
  - **Required approving reviews:** 1 (or more)
  - **Dismiss stale pull request approvals when new commits are pushed:** Yes
- **Require status checks to pass before merging:** Yes
  - Add this required check:
    - `Validate PR Target` (from `pr-validation.yml`)
- **Require branches to be up to date before merging:** Yes
- **Do not allow bypassing the above settings:** Yes (recommended)
- **Restrict who can push to matching branches:** Only allow merge via PR

### `develop` Branch

- **Branch name pattern:** `develop`
- **Require a pull request before merging:** Yes
  - **Required approving reviews:** 1 (or more)
- **Require status checks to pass before merging:** Yes
  - Add these required checks:
    - `Validate PR Target` (from `pr-validation.yml`)
    - `Run Checks` (from `feature.yml`)
- **Require branches to be up to date before merging:** Yes
- **Do not allow bypassing the above settings:** Optional

### `release/*` Branches (Optional)

If you want to protect active release branches:

- **Branch name pattern:** `release/**`
- **Require a pull request before merging:** Yes
- **Require status checks to pass before merging:** Yes
  - Add: `Validate PR Target`

## Notes

- The `GITHUB_TOKEN` used by workflows needs write access to create tags and PRs. This is the default for non-fork PRs.
- Tags pushed with `GITHUB_TOKEN` do not trigger subsequent workflows (GitHub limitation). To enable automatic GitHub Releases via `tag-release.yml`, use a Personal Access Token or GitHub App token — see the [Customization section](../README.md#using-a-custom-token) in the README.
- The included ruleset files use the GitHub Rulesets format (not legacy branch protection). Rulesets are the recommended approach and support import/export via UI and API.
- The `integration_id: 15368` in ruleset files is the GitHub.com Actions app ID. For GitHub Enterprise Server, you may need to update this value.
- For organizations, consider applying rulesets at the organization level for consistent enforcement across repositories.
