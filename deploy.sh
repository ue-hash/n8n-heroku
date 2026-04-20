#!/usr/bin/env bash
set -euo pipefail

APPS_FILE="$(dirname "$0")/heroku-apps.txt"
SCRIPT_NAME="$(basename "$0")"

usage() {
  echo "Usage: $SCRIPT_NAME <app-name> [app-name ...]"
  echo ""
  echo "Deploys the current branch to the specified Heroku app(s)."
  echo "App names must be listed in heroku-apps.txt."
  echo ""
  echo "Available apps:"
  grep -v '^\s*#' "$APPS_FILE" | grep -v '^\s*$' | sed 's/^/  /'
  exit 1
}

# Load known apps into an array
mapfile -t KNOWN_APPS < <(grep -v '^\s*#' "$APPS_FILE" | grep -v '^\s*$')

if [[ ${#KNOWN_APPS[@]} -eq 0 ]]; then
  echo "Error: no apps defined in heroku-apps.txt"
  exit 1
fi

if [[ $# -eq 0 ]]; then
  usage
fi

# Validate all args before deploying anything
TARGETS=()
for app in "$@"; do
  found=false
  for known in "${KNOWN_APPS[@]}"; do
    if [[ "$app" == "$known" ]]; then
      found=true
      break
    fi
  done
  if [[ "$found" == false ]]; then
    echo "Error: '$app' is not listed in heroku-apps.txt"
    echo "Run '$SCRIPT_NAME' with no arguments to see available apps."
    exit 1
  fi
  TARGETS+=("$app")
done

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
echo "Deploying branch '$BRANCH' to: ${TARGETS[*]}"
echo ""

for app in "${TARGETS[@]}"; do
  echo "==> $app"
  git push "https://git.heroku.com/${app}.git" "${BRANCH}:main"
  echo ""
done

echo "Done."
