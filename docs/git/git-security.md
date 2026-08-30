# Git Security

## Objective

Protect source code, credentials, secrets and sensitive configuration from accidental exposure.

## .gitignore

The project contains a .gitignore file.

Important ignored files include:

.env
.env.*
.env.local

The example configuration remains tracked:

!.env.example

## Secrets

Real secrets must never be committed to Git.

Examples:

- Database passwords
- API keys
- Access tokens
- Cloud credentials
- Private keys
- TLS certificates
- Service credentials

Use environment variables or an approved secret-management solution.

## Environment Files

Allowed:

.env.example

Not allowed:

.env
.env.development
.env.production
.env.local

Real environment files should remain local or be managed through a secure secret-management mechanism.

## Keys and Certificates

The repository ignores:

*.pem
*.key
*.crt
*.cert
*.p12
*.pfx

These files may contain private credentials or cryptographic material.

## Logs

The repository ignores:

*.log
logs/

Logs may contain sensitive information and should not normally be committed.

## Dependencies

The repository ignores:

node_modules/

Dependencies should be installed using package.json and package-lock.json.

## Build Output

The repository ignores generated build directories such as:

dist/
build/

## Security Validation

Check whether environment files are tracked:

git ls-files .env .env.development .env.production

Expected:

No output.

Search tracked files for potentially sensitive names:

git ls-files | Select-String -Pattern "\.env$|\.env\.|secret|password|credential"

This command should be reviewed manually because filenames such as password.js do not automatically indicate a secret.

## Secret Scan

Before committing important changes, review the diff:

git diff

Also review staged changes:

git diff --cached

## If a Secret Is Accidentally Committed

Do not simply delete the file and assume the secret is safe.

The exposed credential should be considered compromised.

Recommended response:

1. Revoke or rotate the credential.
2. Remove the secret from the repository.
3. Review Git history.
4. Check GitHub security alerts/scanning.
5. Replace the credential securely.
6. Notify the responsible team if required.

## Current Security Status

The local .gitignore protects environment files, keys, certificates, logs and other generated/local files.

Current validation confirmed that .env files are not tracked.

The repository intentionally tracks .env.example.

GitHub-side security controls such as secret scanning, push protection, Dependabot and branch protection must only be documented as enabled after verification.
