#!/bin/bash
set -e

NEW_VERSION=$(node -p "require('./package.json').version")

echo "Generating changelog for v$NEW_VERSION..."

LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)

LOG_ENTRIES=$(git log "$LAST_TAG..HEAD" --oneline --no-decorate 2>/dev/null | sed 's/^/- /' || true)

CHANGELOG_ENTRY="## [$NEW_VERSION] - $(date +%Y-%m-%d)

$LOG_ENTRIES
"

if [ -f CHANGELOG.md ]; then
  echo "$CHANGELOG_ENTRY" | cat - CHANGELOG.md > /tmp/changelog.tmp
  mv /tmp/changelog.tmp CHANGELOG.md
else
  echo "$CHANGELOG_ENTRY" > CHANGELOG.md
fi

echo "Changelog updated"
