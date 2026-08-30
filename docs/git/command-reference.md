# Git Command Reference

## Repository

git init

git status

git remote -v

## Branches

git branch

git branch -a

git switch main

git switch -c feature/<name>

## Changes

git status

git diff

git diff --cached

git add .

git add FILE

git restore FILE

git restore --staged FILE

## Commits

git commit -m "message"

git log --oneline

git log --oneline --decorate --graph --all

## Remote

git fetch origin

git pull origin main

git push

git push -u origin feature/<name>

## Branch Cleanup

git branch -d feature/<name>

## Useful Inspection

git ls-files

git ls-files .env .env.development .env.production

git show <commit>

git diff main origin/main

## Safe Workflow

git status

git switch main

git pull origin main

git switch -c feature/<name>

# Make changes

git status

git diff

git add .

git diff --cached

git commit -m "descriptive message"

git push -u origin feature/<name>

# Create Pull Request

# After merge

git switch main

git pull origin main
