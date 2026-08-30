# Pull Request Workflow

## Purpose

Pull Requests are used to review changes before integrating them into the main branch.

## Standard Workflow

1. Synchronize main.
2. Create a short-lived branch.
3. Make the required changes.
4. Test the changes locally.
5. Review the Git diff.
6. Commit the changes.
7. Push the branch to GitHub.
8. Create a Pull Request.
9. Run CI and security checks.
10. Review the changes.
11. Resolve requested changes.
12. Merge the Pull Request.
13. Delete the short-lived branch.
14. Synchronize local main.

## Commands

Update main:

git switch main

git pull origin main

Create branch:

git switch -c feature/<name>

Check status:

git status

Review changes:

git diff

Stage:

git add .

Commit:

git commit -m "descriptive commit message"

Push:

git push -u origin feature/<name>

## Pull Request

A Pull Request should contain:

### Title

A short description of the change.

Example:

Dockerize application services

### Description

The description should explain:

- What changed
- Why it changed
- How it was tested
- Any known limitations

## Review

Before merging:

- CI should pass.
- Security checks should pass.
- The change should be reviewed.
- No unintended files should be included.
- No secrets should be committed.

## Merge

After approval and successful checks:

Pull Request

        |

        v

Merge

        |

        v

main

## After Merge

Update local repository:

git switch main

git pull origin main

Delete local branch if no longer required:

git branch -d feature/<name>

## Important Rule

Do not directly commit unrelated changes to a feature branch.

Keep commits focused and meaningful.

## Current Implementation Status

The local repository currently uses main and origin/main.

The PR workflow described here is the intended project workflow.

GitHub PR rules and required checks will be recorded as implemented after they are verified/configured on GitHub.
