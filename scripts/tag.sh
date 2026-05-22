#!/bin/bash
set -e

NEW_VERSION=$(node -p "require('./package.json').version")

echo "Committing and tagging v$NEW_VERSION..."

git config user.name "version-orchestrator[bot]"
git config user.email "version-orchestrator[bot]@users.noreply.github.com"

git add package.json
[ -f package-lock.json ] && git add package-lock.json
[ -f pnpm-lock.yaml ] && git add pnpm-lock.yaml
git add CHANGELOG.md

git commit -m "chore: bump to v$NEW_VERSION [skip ci]"

git tag "v$NEW_VERSION"

git push origin HEAD --tags

gh release create "v$NEW_VERSION" \
  --title "v$NEW_VERSION" \
  --notes "$(git log -1 --oneline --no-decorate)" \
  --verify-tag

echo "Release v$NEW_VERSION created"
