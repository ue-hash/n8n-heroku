#!/usr/bin/env bash
set -euo pipefail

APPS_FILE="$(dirname "$0")/heroku-apps.txt"
SCRIPT_NAME="$(basename "$0")"

# Populates KNOWN_APPS (array) and APP_COMMENTS (associative array)
load_known_apps() {
  KNOWN_APPS=()
  declare -gA APP_COMMENTS
  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*$ ]] && continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    app="${line%%#*}"
    app="${app%"${app##*[! ]}"}"  # rtrim
    comment=""
    if [[ "$line" == *"#"* ]]; then
      comment="${line#*#}"
      comment="${comment#"${comment%%[! ]*}"}"  # ltrim
    fi
    KNOWN_APPS+=("$app")
    APP_COMMENTS["$app"]="$comment"
  done < "$APPS_FILE"

  if [[ ${#KNOWN_APPS[@]} -eq 0 ]]; then
    echo "Error: no apps defined in heroku-apps.txt"
    exit 1
  fi
}

n8n_version_at() {
  local ref="$1"
  git show "${ref}:Dockerfile" 2>/dev/null | grep '^FROM' | sed 's/.*n8n://' | tr -d '[:space:]'
}

cmd_status() {
  load_known_apps
  printf "%-35s %-15s %-20s %-15s %s\n" "APP" "N8N VERSION" "DEPLOYED AT" "BRANCH" "NOTE"
  printf "%-35s %-15s %-20s %-15s %s\n" "---" "-----------" "-----------" "------" "----"
  for app in "${KNOWN_APPS[@]}"; do
    tag="deployed/${app}"
    note="${APP_COMMENTS[$app]:-}"
    if git rev-parse --verify --quiet "refs/tags/${tag}" > /dev/null 2>&1; then
      version="$(n8n_version_at "${tag}")"
      deployed_at="$(git log -1 --format="%ci" "${tag}" | cut -d' ' -f1,2 | cut -d':' -f1,2)"
      branch="$(git tag -l --format='%(contents)' "${tag}" | grep '^branch:' | cut -d' ' -f2)"
      printf "%-35s %-15s %-20s %-15s %s\n" "$app" "$version" "$deployed_at" "${branch:-(unknown)}" "$note"
    else
      printf "%-35s %-15s %-20s %-15s %s\n" "$app" "(never deployed)" "" "" "$note"
    fi
  done
}

cmd_deploy() {
  load_known_apps

  TARGETS=()
  for app in "$@"; do
    found=false
    for known in "${KNOWN_APPS[@]}"; do
      [[ "$app" == "$known" ]] && { found=true; break; }
    done
    if [[ "$found" == false ]]; then
      echo "Error: '$app' is not listed in heroku-apps.txt"
      echo "Run '$SCRIPT_NAME status' to see all apps and their current versions."
      exit 1
    fi
    TARGETS+=("$app")
  done

  BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  VERSION="$(n8n_version_at HEAD)"
  ORIGIN_SSH="$(git remote get-url origin | sed 's|https://github.com/|git@github.com:|')"
  echo "Deploying n8n:${VERSION} from branch '${BRANCH}' to: ${TARGETS[*]}"
  echo ""

  for app in "${TARGETS[@]}"; do
    note="${APP_COMMENTS[$app]:-}"
    echo "==> $app${note:+ ($note)}"
    git push "https://git.heroku.com/${app}.git" "${BRANCH}:main"
    git tag -f -a "deployed/${app}" -m "$(printf 'branch: %s\nn8n: %s' "$BRANCH" "$VERSION")"
    git push -f "$ORIGIN_SSH" "refs/tags/deployed/${app}"
    echo "    tagged: deployed/${app} -> n8n:${VERSION}"
    echo ""
  done

  echo "Done."
}

usage() {
  echo "Usage:"
  echo "  $SCRIPT_NAME status                      Show deployed version for all apps"
  echo "  $SCRIPT_NAME <app-name> [app-name ...]   Deploy current branch to app(s)"
  echo ""
  echo "Available apps:"
  load_known_apps
  for app in "${KNOWN_APPS[@]}"; do
    note="${APP_COMMENTS[$app]:-}"
    printf "  %-30s %s\n" "$app" "$note"
  done
  exit 1
}

case "${1:-}" in
  status) cmd_status ;;
  "")     usage ;;
  *)      cmd_deploy "$@" ;;
esac
