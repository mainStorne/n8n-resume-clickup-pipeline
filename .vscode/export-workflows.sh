#!/usr/bin/env bash
# Package every workflow on the n8n instance (plus any sub-workflow
# dependencies, credentials, data tables and tags they reference) into a
# single n8n-cli package bundle.
#
# Requires: n8n-cli logged in / configured (n8n-cli login, or N8N_URL +
# N8N_API_KEY env vars) and pointed at a reachable n8n instance.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

OUTPUT="${1:-export.n8np}"

mapfile -t WORKFLOW_IDS < <(n8n-cli workflow list --json | jq -r '.[].id')

if [ "${#WORKFLOW_IDS[@]}" -eq 0 ]; then
  echo "No workflows found on the instance — nothing to export." >&2
  exit 1
fi

echo "Packaging ${#WORKFLOW_IDS[@]} workflow(s) into ${OUTPUT}..."

ARGS=()
for id in "${WORKFLOW_IDS[@]}"; do
  ARGS+=(-w "$id")
done

n8n-cli package export "${ARGS[@]}" \
  --missingWorkflowDependencyPolicy include-in-package \
  --output "$OUTPUT"

echo "Wrote $OUTPUT"
