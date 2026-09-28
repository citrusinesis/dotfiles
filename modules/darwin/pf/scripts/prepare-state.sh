#!/bin/sh

set -eu
umask 077

state_file=$1
current_anchor=$2
state_candidate=

if ! /usr/bin/printf '%s\n' "$current_anchor" | /usr/bin/grep -Eq '^[A-Za-z0-9_.-]+$'; then
  /usr/bin/printf 'Refusing to install an invalid PF anchor: %s\n' "$current_anchor" >&2
  exit 1
fi

if [ -f "$state_file" ]; then
  previous_anchor=$(/bin/cat "$state_file")
  if ! /usr/bin/printf '%s\n' "$previous_anchor" | /usr/bin/grep -Eq '^[A-Za-z0-9_.-]+$'; then
    /usr/bin/printf 'Refusing to replace an invalid managed PF anchor: %s\n' "$previous_anchor" >&2
    exit 1
  fi

  if [ "$previous_anchor" != "$current_anchor" ]; then
    /sbin/pfctl -a "com.apple/$previous_anchor" -F rules
    /sbin/pfctl -a "$previous_anchor" -F rules

    previous_anchor_path="/etc/pf.anchors/$previous_anchor"
    if [ -e "$previous_anchor_path.before-nix-darwin" ]; then
      /bin/mv -f "$previous_anchor_path.before-nix-darwin" "$previous_anchor_path"
    fi
  fi
fi

cleanup() {
  if [ -n "$state_candidate" ]; then
    /bin/rm -f "$state_candidate"
  fi
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM

state_candidate=$(/usr/bin/mktemp "$state_file.XXXXXX")
/usr/bin/printf '%s\n' "$current_anchor" > "$state_candidate"
/bin/chmod 600 "$state_candidate"
/usr/sbin/chown root:wheel "$state_candidate"
/bin/mv -f "$state_candidate" "$state_file"
state_candidate=
