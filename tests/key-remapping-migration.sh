#!/usr/bin/env bash
set -euo pipefail

migration="$1"
service="gui/$UID/com.local.KeyRemapping"
legacy=/Library/LaunchAgents/com.local.KeyRemapping.plist
current="$PWD/Home Manager/LaunchAgents/com.local.KeyRemapping.plist"
macosVersion=26.0
bootoutFailure=0
dryRun=0
mkdir -p "${current%/*}"
touch "$current" calls

fakeLaunchctl() {
  local action="$1"
  shift
  case "$action" in
    print)
      [[ "$1" == "$service" && -f registered ]] || return 113
      printf '%s = {\n\tpath = %s\n}\n' "$service" "$(cat registered)"
      ;;
    bootout)
      printf 'bootout %s\n' "$*" >> calls
      [[ "${*: -1}" == "$service" ]]
      [[ "$bootoutFailure" == 0 ]] || return 5
      rm registered
      ;;
    bootstrap)
      [[ "$1" == "gui/$UID" && "$2" == "$current" && -f "$current" ]]
      [[ ! -f registered ]] || return 5
      printf '%s\n' "$current" > registered
      ;;
    *) return 64 ;;
  esac
}
fakeSwVers() { printf '%s\n' "$macosVersion"; }
verboseEcho() { :; }
run() {
  [[ "$dryRun" == 0 ]] || return 0
  "$@"
}
migrate() {
  # shellcheck disable=SC1090
  source "$migration"
}

# Reproduce a failed switch: the new plist exists, but the deleted legacy path
# is still registered. Bootstrap fails until the migration unloads that job.
printf '%s\n' "$legacy" > registered
if fakeLaunchctl bootstrap "gui/$UID" "$current"; then exit 1; fi
migrate
grep -Fx "bootout --wait $service" calls
fakeLaunchctl bootstrap "gui/$UID" "$current"

# The migrated job, an unrelated same-label job, and an absent job are untouched.
: > calls
migrate
printf '%s.backup\n' "$legacy" > registered
migrate
rm registered
migrate
[[ ! -s calls ]]

# A dry run must leave the registration in place.
printf '%s\n' "$legacy" > registered
dryRun=1
migrate
[[ "$(cat registered)" == "$legacy" && ! -s calls ]]
dryRun=0

# Do not hide a genuine unload failure or proceed to a conflicting bootstrap.
bootoutFailure=1
if migrate; then exit 1; fi
[[ "$(cat registered)" == "$legacy" ]]
bootoutFailure=0

# Older macOS has no bootout --wait; allow it to finish before bootstrap.
macosVersion=15.0
: > calls
migrate
grep -Fx "bootout $service" calls
fakeLaunchctl bootstrap "gui/$UID" "$current"
