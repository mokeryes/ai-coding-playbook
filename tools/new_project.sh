#!/usr/bin/env bash
# Convenience wrapper around `cruft create` with sensible defaults.
#
# Usage:
#   ./tools/new_project.sh           # interactive
#   ./tools/new_project.sh --no-input project_name="My Project" primary_language=swift
#
# Requires: pip install cruft

set -euo pipefail

if ! command -v cruft >/dev/null 2>&1; then
  echo "ERROR: cruft is not installed."
  echo "  pip install cruft"
  exit 1
fi

REPO_URL="${PLAYBOOK_REPO:-https://github.com/mokeryes/ai-coding-playbook}"

echo "[new_project] using template: $REPO_URL"
exec cruft create "$REPO_URL" "$@"
