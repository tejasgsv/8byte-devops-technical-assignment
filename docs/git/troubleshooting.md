# Git Troubleshooting

## Check Repository Status

git status

Use this first to identify:

- Modified files
- Deleted files
- Untracked files
- Staged files
- Current branch

## Check Remote

git remote -v

Expected remote:

origin

## Local Branch Behind Remote

Update local branch:

git pull origin main

## Local Branch Ahead of Remote

Push changes:

git push origin main

For a feature branch:

git push -u origin feature/<name>

## Uncommitted Changes

Check:

git status

Review:

git diff

Stage:

git add .

Commit:

git commit -m "descriptive message"

## Accidentally Staged a File

Remove from staging:

git restore --staged FILE

The file remains modified in the working directory.

## Discard Local Changes

Use carefully:

git restore FILE

This removes uncommitted changes from that file.

## Merge Conflict

Check:

git status

Open the conflicted files.

Resolve the conflict manually.

Then:

git add .

Commit the resolution:

git commit

## Branch Synchronization

Fetch remote changes:

git fetch origin

Review branches:

git branch -a

Update main:

git switch main

git pull origin main

## View History

git log --oneline

Graph view:

git log --oneline --decorate --graph --all

## Compare With Remote

git fetch origin

git diff main origin/main

## Verify Tracked Environment Files

git ls-files .env .env.development .env.production

Expected:

No output.

## Useful Windows Portability Note

PowerShell commands are used in this project because development is currently being performed on Windows.

## Troubleshooting Approach

1. Check git status.
2. Check current branch.
3. Check remote.
4. Fetch remote changes.
5. Review diff.
6. Resolve conflicts carefully.
7. Run tests.
8. Commit only intended changes.
9. Push.
10. Verify Pull Request checks.

## Important

Never use destructive commands such as:

git reset --hard

or

git clean -fd

unless you understand exactly which local changes/files will be removed.
