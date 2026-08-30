# Git Overview

## Project

8Byte Full-Stack E-Commerce DevOps Project

## Purpose

Git is used for source code version control and collaboration.

The repository contains the application source code, Docker configuration, infrastructure configuration and DevOps documentation.

## Current Repository

Remote:

origin

Repository:

8byte-devops-technical-assignment

Current branch:

main

## Current Git Status

The local repository is connected to the GitHub remote repository.

The current working branch is:

main

The local main branch tracks:

origin/main

## Git Repository Flow

Local Working Directory
        |
        v
Git Repository
        |
        v
Commit
        |
        v
GitHub Remote
        |
        v
Pull Request
        |
        v
Code Review / CI Checks
        |
        v
Merge
        |
        v
main

## Important Git Concepts

### Working Directory

Contains the files currently being modified.

### Staging Area

Files selected for the next commit using:

git add

### Commit

A snapshot of changes created using:

git commit

### Branch

An independent line of development.

### Remote

The GitHub repository connected to the local repository.

The configured remote is:

origin

## Useful Commands

Check Git version:

git --version

Check repository status:

git status

Check branches:

git branch

Check remote:

git remote -v

Check commit history:

git log --oneline

Check detailed history:

git log --oneline --decorate --graph --all

Stage a file:

git add FILE

Stage all changes:

git add .

Create a commit:

git commit -m "commit message"

Push changes:

git push

Pull changes:

git pull

Fetch remote changes:

git fetch

## Repository Security

The repository uses .gitignore to prevent sensitive and unnecessary files from being committed.

Examples include:

- .env files
- local environment files
- private keys
- certificates
- logs
- node_modules
- build output
- IDE files

The example environment file is intentionally allowed:

.env.example

Real environment files must not be committed.

## Current State

The repository currently contains the initial application baseline and local DevOps changes are being prepared for version control.
