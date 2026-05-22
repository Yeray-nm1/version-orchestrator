#!/bin/bash
set -e

BUMP="${BUMP:-patch}"

echo "Bumping version ($BUMP)..."

if [ -f "pnpm-lock.yaml" ]; then
  pnpm version "$BUMP" --no-git-tag-version
elif [ -f "package-lock.json" ]; then
  npm version "$BUMP" --no-git-tag-version
else
  npm version "$BUMP" --no-git-tag-version
fi

NEW_VERSION=$(node -p "require('./package.json').version")
echo "New version: $NEW_VERSION"
