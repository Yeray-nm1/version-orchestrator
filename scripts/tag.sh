#!/bin/bash
set -e

if [ -f "pom.xml" ]; then
  NEW_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout 2>/dev/null)
else
  NEW_VERSION=$(node -p "require('./package.json').version")
fi

echo "Committing and tagging v$NEW_VERSION..."

git config user.name "version-orchestrator[bot]"
git config user.email "version-orchestrator[bot]@users.noreply.github.com"

if [ -f "pom.xml" ]; then
  git add pom.xml
  # Also add any backup pom files that might have been generated
  git add -A "*pom.xml" 2>/dev/null || true
fi
[ -f package.json ] && git add package.json
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
