# Branch Protection Rules

Recommended GitHub branch protection settings to enforce Gitflow.

## `main` Branch

Go to **Settings > Branches > Add rule** and configure:

- **Branch name pattern:** `main`
- **Require a pull request before merging:** Yes
  - **Required approving reviews:** 1 (or more)
  - **Dismiss stale pull request approvals when new commits are pushed:** Yes
- **Require status checks to pass before merging:** Yes
  - Add these required checks:
    - `Validate PR Target` (from `pr-validation.yml`)
    - `Validate Release` (from `release.yml`)
    - `Validate Hotfix` (from `hotfix.yml`)
- **Require branches to be up to date before merging:** Yes
- **Do not allow bypassing the above settings:** Yes (recommended)
- **Restrict who can push to matching branches:** Only allow merge via PR

## `develop` Branch

- **Branch name pattern:** `develop`
- **Require a pull request before merging:** Yes
  - **Required approving reviews:** 1 (or more)
- **Require status checks to pass before merging:** Yes
  - Add these required checks:
    - `Validate PR Target` (from `pr-validation.yml`)
    - `Run Checks` (from `feature.yml`)
- **Require branches to be up to date before merging:** Yes
- **Do not allow bypassing the above settings:** Optional

## `release/*` Branches (Optional)

If you want to protect active release branches:

- **Branch name pattern:** `release/**`
- **Require a pull request before merging:** Yes
- **Require status checks to pass before merging:** Yes
  - Add: `Validate PR Target`

## Notes

- The `GITHUB_TOKEN` used by workflows needs write access to create tags and PRs. This is the default for non-fork PRs.
- If you use **Rulesets** (newer GitHub feature) instead of branch protection rules, the same settings apply — just configured through the Rulesets UI.
- For organizations, consider setting these rules at the organization level using repository rulesets.
