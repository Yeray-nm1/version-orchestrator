#!/bin/bash
set -e

BUMP="${BUMP:-patch}"

echo "Bumping version ($BUMP)..."

if [ -f "pom.xml" ]; then
  CURRENT_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout 2>/dev/null)
  BASE_VERSION=$(echo "$CURRENT_VERSION" | sed 's/-SNAPSHOT//' | sed 's/-dev\.[0-9]*//')

  MAJOR=$(echo "$BASE_VERSION" | cut -d. -f1)
  MINOR=$(echo "$BASE_VERSION" | cut -d. -f2)
  PATCH=$(echo "$BASE_VERSION" | cut -d. -f3)

  case "$BUMP" in
    major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
    minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
    patch) PATCH=$((PATCH + 1)) ;;
  esac

  NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
  mvn -B versions:set -DnewVersion="$NEW_VERSION" -DgenerateBackupPoms=false

elif [ -f "pnpm-lock.yaml" ]; then
  pnpm version "$BUMP" --no-git-tag-version

elif [ -f "package-lock.json" ] || [ -f "package.json" ]; then
  npm version "$BUMP" --no-git-tag-version

else
  echo "No supported project detected (pom.xml or package.json)"
  exit 1
fi

echo "Version bumped"
