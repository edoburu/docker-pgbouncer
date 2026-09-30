#!/usr/bin/env bash
# Characterization tests for entrypoint.sh: each case directory holds the env it
# runs with and the config expected from it. UPDATE_EXPECTED=1 rewrites those.
set -euo pipefail

image="${IMAGE:-edoburu/pgbouncer:test}"
update_expected="${UPDATE_EXPECTED:-0}"

tests_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

work_root=$(mktemp -d)
trap 'rm -rf "$work_root"' EXIT

# The entrypoint keeps these paths to itself, so the dump command repeats them.
dump_command='cp /etc/pgbouncer/pgbouncer.ini /out/pgbouncer.ini
cp "${AUTH_FILE:-/etc/pgbouncer/userlist.txt}" /out/userlist.txt'

failed_cases=""

read_directive() {
  awk -v name="$1" '
    $0 ~ "^# "name":" { sub("^# "name": *", ""); print; exit }
  ' "$2"
}

compare_artifact() {
  local expected_file="$1" actual_file="$2"

  if [ "$update_expected" = "1" ]; then
    mkdir -p "$(dirname "$expected_file")"
    cp "$actual_file" "$expected_file"
    return 0
  fi

  if [ ! -f "$expected_file" ]; then
    echo "  missing $expected_file — rerun with UPDATE_EXPECTED=1"
    return 1
  fi

  diff -u "$expected_file" "$actual_file"
}

# pgbouncer parses its config only at startup, so booting the container is the
# only proof that a rendered file is valid and not merely unchanged.
assert_boots() {
  local env_file="$1" container deadline

  container=$(docker run -d --env-file "$env_file" "$image")
  deadline=$((SECONDS + 30))

  while [ "$SECONDS" -lt "$deadline" ]; do
    if docker logs "$container" 2>&1 | grep -q "process up:"; then
      docker rm -f "$container" > /dev/null
      return 0
    fi

    if [ -z "$(docker ps -q --filter "id=$container")" ]; then
      break
    fi

    sleep 1
  done

  echo "  pgbouncer did not start:"
  docker logs "$container" 2>&1 | awk '{ print "    " $0 }'
  docker rm -f "$container" > /dev/null
  return 1
}

for env_file in "$tests_dir"/*/env; do
  case_dir=$(dirname "$env_file")
  case_name=$(basename "$case_dir")
  expectation=$(read_directive expect "$env_file")
  boots=$(read_directive boot "$env_file")
  expected_dir="$case_dir/expected"
  work_dir="$work_root/$case_name"
  case_failed=0

  echo "== $case_name"

  mkdir -p "$work_dir"
  chmod 0777 "$work_dir" # the image runs as postgres, not as root

  docker_args=(--rm --env-file "$env_file" --volume "$work_dir:/out")

  # A case may ship a config to assert the entrypoint leaves an existing one alone.
  if [ -f "$case_dir/existing.ini" ]; then
    cp "$case_dir/existing.ini" "$work_dir/existing.ini"
    chmod 0666 "$work_dir/existing.ini"
    docker_args+=(--volume "$work_dir/existing.ini:/etc/pgbouncer/pgbouncer.ini")
  fi

  render_status=0
  docker run "${docker_args[@]}" "$image" sh -c "$dump_command" \
    > "$work_dir/output.txt" 2>&1 || render_status=$?

  if [ "${expectation:-success}" = "failure" ]; then
    if [ "$render_status" -eq 0 ]; then
      echo "  expected a non-zero exit, got 0"
      case_failed=1
    fi

    compare_artifact "$expected_dir/output.txt" "$work_dir/output.txt" || case_failed=1
  else
    if [ "$render_status" -ne 0 ]; then
      echo "  entrypoint exited $render_status:"
      awk '{ print "    " $0 }' "$work_dir/output.txt"
      case_failed=1
    else
      compare_artifact "$expected_dir/pgbouncer.ini" "$work_dir/pgbouncer.ini" \
        || case_failed=1
      compare_artifact "$expected_dir/userlist.txt" "$work_dir/userlist.txt" \
        || case_failed=1
    fi

    if [ "$update_expected" != "1" ]; then
      case "${boots:-no}" in
        yes)
          assert_boots "$env_file" || case_failed=1
          ;;

        fails)
          if assert_boots "$env_file" > /dev/null 2>&1; then
            echo "  expected pgbouncer to reject this config, it started"
            case_failed=1
          fi
          ;;
      esac
    fi
  fi

  if [ "$case_failed" -ne 0 ]; then
    failed_cases="$failed_cases $case_name"
  fi
done

echo

if [ -n "$failed_cases" ]; then
  echo "FAILED:$failed_cases"
  exit 1
fi

if [ "$update_expected" = "1" ]; then
  echo "Expectations updated — review the diff before committing."
else
  echo "All cases match their expectations."
fi
