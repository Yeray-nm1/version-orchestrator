#!/bin/bash
set -e

BUMP="${BUMP:-patch}"

echo "Bumping version ($BUMP)..."

if [ -f "pom.xml" ]; then
  CURRENT_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout 2>/dev/null)
  BASE_VERSION="${CURRENT_VERSION%-SNAPSHOT}"

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

elif [ -f "package.json" ]; then
  node -e "
    const p = JSON.parse(require('fs').readFileSync('package.json','utf8'));
    const base = p.version.replace(/-.*$/, '');
    let [major, minor, patch] = base.split('.').map(Number);
    const bump = '$BUMP';
    if (bump === 'major') { major++; minor = 0; patch = 0; }
    else if (bump === 'minor') { minor++; patch = 0; }
    else if (bump === 'patch') { patch++; }
    p.version = major + '.' + minor + '.' + patch;
    require('fs').writeFileSync('package.json', JSON.stringify(p, null, 2) + '\n');
    console.log('v' + p.version);
  "

else
  echo "No supported project detected (pom.xml or package.json)"
  exit 1
fi

echo "Version bumped"
