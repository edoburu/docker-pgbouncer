#!/usr/bin/env bash
# Fails when entrypoint.sh reads a variable no case exercises, so a new knob
# cannot land untested. Line coverage misses them: they share two printfs.
set -euo pipefail

tests_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
entrypoint="$tests_dir/../entrypoint.sh"

# Set by the script itself, so not part of the container's interface.
internal_variables="PG_CONFIG_DIR PG_CONFIG_FILE _AUTH_FILE"

referenced=$(
  grep -oE '\$\{?[A-Z_][A-Z0-9_]*' "$entrypoint" \
    | tr -d '${' \
    | sort -u
)

exercised=$(
  {
    grep -hoE '^[A-Z_][A-Z0-9_]*=' "$tests_dir"/*/env | tr -d '='
    echo "$internal_variables" | tr ' ' '\n'
  } | sort -u
)

uncovered=$(comm -23 <(echo "$referenced") <(echo "$exercised"))
referenced_count=$(echo "$referenced" | grep -c .)
uncovered_count=$(echo "$uncovered" | grep -c . || true)

echo "entrypoint.sh reads $referenced_count variables, \
$((referenced_count - uncovered_count)) exercised by a test case"

if [ "$uncovered_count" -ne 0 ]; then
  echo
  echo "Never set by any case:"
  echo "$uncovered" | awk '{ print "  " $0 }'
  echo
  echo "Add them to tests/all-knobs/env, or to internal_variables here if"
  echo "they are not part of the container's interface."
  exit 1
fi
