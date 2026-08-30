# Git Branching Strategy

## Strategy

The project follows a Trunk-Based Development approach.

The main branch represents the primary development trunk.

Changes should be kept small and short-lived.

## Main Branch

Branch:

main

Purpose:

- Primary integration branch
- Stable source of the project
- Final destination for reviewed changes

## Short-Lived Branches

For larger changes, use short-lived branches.

Recommended naming:

feature/<name>

Examples:

feature/dockerization

feature/kubernetes

feature/monitoring

feature/terraform

fix/inventory-service

fix/gateway-routing

docs/docker-documentation

## Development Flow

main
 |
 +----> feature/change
 |             |
 |             +----> commit
 |             |
 |             +----> push
 |             |
 |             +----> Pull Request
 |                         |
 |                         +----> CI / Security Checks
 |                         |
 |                         +----> Review
 |                         |
 |                         +----> Merge
 |                                  |
 +----------------------------------+
                  |
                  v
                 main

## Trunk-Based Principles

1. Keep branches short-lived.
2. Make small commits.
3. Keep main stable.
4. Frequently synchronize with main.
5. Use Pull Requests when review is required.
6. Do not keep long-lived feature branches.
7. Avoid unrelated changes in the same commit.

## Before Starting Work

Update local main:

git switch main

git pull origin main

Create a short-lived branch:

git switch -c feature/<name>

## After Completing Work

Check changes:

git status

Review changes:

git diff

Stage changes:

git add .

Commit:

git commit -m "descriptive message"

Push:

git push -u origin feature/<name>

Then create a Pull Request.

## Branch Naming Guidelines

Use lowercase names.

Use hyphens instead of spaces.

Examples:

feature/docker-compose

feature/github-actions

feature/kubernetes-deployment

fix/catalog-startup

docs/git-workflow

## Current Implementation Status

The repository currently has:

main

The short-lived branch workflow is documented here as the intended development strategy.

GitHub branch protection and PR enforcement should be documented as implemented only after those settings are verified on the GitHub repository.
