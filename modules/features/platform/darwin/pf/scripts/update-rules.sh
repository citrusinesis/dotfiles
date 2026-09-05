#!/bin/sh

set -eu
umask 077

runtime_anchor=$1
tailscale_v4=$2
tailscale_v6=$3
pass_rules_file=$4
block_rules_file=$5
lock_file=$6
lock_attempts=0

load_anchor() {
  if ! pfctl_output=$(
    /sbin/pfctl \
      -a "$runtime_anchor" \
      -R \
      -o none \
      -f "$1" 2>&1
  ); then
    /usr/bin/printf '%s\n' "$pfctl_output" >&2
    return 1
  fi

  # Apple's pfctl emits this main-ruleset warning even for an isolated anchor
  # transaction. Keep every other successful diagnostic visible.
  /usr/bin/printf '%s\n' "$pfctl_output" | /usr/bin/awk '
    $0 == "pfctl: Use of -f option, could result in flushing of rules" { next }
    $0 == "present in the main ruleset added by the system at startup." { next }
    $0 == "See /etc/pf.conf for further details." { next }
    NF { print > "/dev/stderr" }
  '
}

while ! /usr/bin/shlock -p "$$" -f "$lock_file"; do
  lock_attempts=$((lock_attempts + 1))
  if [ "$lock_attempts" -ge 30 ]; then
    /usr/bin/printf 'Timed out waiting for the PF activation lock: %s\n' "$lock_file" >&2
    exit 1
  fi
  /bin/sleep 1
done

temporary_dir=
cleanup() {
  if [ -n "$temporary_dir" ]; then
    /bin/rm -rf "$temporary_dir"
  fi
  /bin/rm -f "$lock_file"
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM

# The bootstrap job owns PF enablement and its reference token. If this updater
# wins the launchd race, let bootstrap enable the deny-only rules first.
if ! /sbin/pfctl -s info | /usr/bin/grep -q '^Status: Enabled'; then
  exit 75
fi

temporary_dir=$(/usr/bin/mktemp -d /var/run/tailscale-pf.XXXXXX)
anchor_candidate="$temporary_dir/anchor"

tailscale_if=$(
  /sbin/ifconfig -a | /usr/bin/awk '
    /^[^[:space:]]+:/ {
      interface = $1
      sub(/:$/, "", interface)
    }
    $1 == "inet" {
      split($2, octets, ".")
      if (interface ~ /^utun[0-9]+$/ && octets[1] == 100 && octets[2] >= 64 && octets[2] <= 127) {
        print interface
        exit
      }
    }
    $1 == "inet6" && interface ~ /^utun[0-9]+$/ && tolower($2) ~ /^fd7a:115c:a1e0:/ {
      print interface
      exit
    }
  '
)

if ! /usr/bin/printf '%s\n' "$tailscale_if" | /usr/bin/grep -Eq '^[A-Za-z0-9_.-]+$'; then
  tailscale_if=lo0
  tailscale_ready=false
else
  tailscale_ready=true
fi

{
  /usr/bin/printf 'tailscale_if = "%s"\n' "$tailscale_if"
  /usr/bin/printf 'tailscale_v4 = "%s"\n' "$tailscale_v4"
  /usr/bin/printf 'tailscale_v6 = "%s"\n\n' "$tailscale_v6"

  if "$tailscale_ready"; then
    /bin/cat "$pass_rules_file"
  else
    /usr/bin/printf '%s\n' '# Tailscale is not ready; install deny-only rules and retry.'
  fi

  /bin/cat "$block_rules_file"
} > "$anchor_candidate"

# The existing com.apple/* hook evaluates this direct child anchor. Loading
# filter rules only avoids both the main ruleset and unsupported ALTQ.
load_anchor "$anchor_candidate"

if ! "$tailscale_ready"; then
  exit 75
fi
