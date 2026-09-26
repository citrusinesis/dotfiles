#!/bin/sh

set -eu
umask 077

token_file=$1
lock_file=$2
lock_attempts=0
token_candidate=

while ! /usr/bin/shlock -p "$$" -f "$lock_file"; do
  lock_attempts=$((lock_attempts + 1))
  if [ "$lock_attempts" -ge 30 ]; then
    /usr/bin/printf 'Timed out waiting for the PF activation lock: %s\n' "$lock_file" >&2
    exit 1
  fi
  /bin/sleep 1
done

cleanup() {
  if [ -n "$token_candidate" ]; then
    /bin/rm -f "$token_candidate"
  fi
  /bin/rm -f "$lock_file"
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM

# Validate before changing the active ruleset. Loading the main ruleset here
# also makes this job independent of launchd ordering with com.apple.pfctl.
/sbin/pfctl -q -nf /etc/pf.conf
/sbin/pfctl -q -f /etc/pf.conf

if ! /sbin/pfctl -s info | /usr/bin/grep -q '^Status: Enabled'; then
  if ! pfctl_output=$(/sbin/pfctl -E 2>&1); then
    /usr/bin/printf '%s\n' "$pfctl_output" >&2
    exit 1
  fi

  enable_token=$(
    /usr/bin/printf '%s\n' "$pfctl_output" \
      | /usr/bin/awk 'tolower($1) == "token" && $2 == ":" && $3 ~ /^[0-9]+$/ { print $3; exit }'
  )

  if [ -z "$enable_token" ]; then
    /usr/bin/printf '%s\n' 'pfctl enabled PF without returning a release token' >&2
    exit 1
  fi

  token_candidate=$(/usr/bin/mktemp "$token_file.XXXXXX")
  /usr/bin/printf '%s\n' "$enable_token" > "$token_candidate"
  /bin/chmod 600 "$token_candidate"
  /bin/mv -f "$token_candidate" "$token_file"
  token_candidate=
fi
