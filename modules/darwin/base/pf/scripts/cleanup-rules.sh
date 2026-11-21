#!/bin/sh

set -eu

state_file=$1
token_file=$2
lock_file=$3
default_pf_conf=$4
lock_attempts=0

if [ ! -f "$state_file" ]; then
  exit 0
fi

while ! /usr/bin/shlock -p "$$" -f "$lock_file"; do
  lock_attempts=$((lock_attempts + 1))
  if [ "$lock_attempts" -ge 30 ]; then
    /usr/bin/printf 'Timed out waiting for the PF activation lock: %s\n' "$lock_file" >&2
    exit 1
  fi
  /bin/sleep 1
done
trap '/bin/rm -f "$lock_file"' EXIT
trap 'exit 1' HUP INT TERM

managed_anchor=$(/bin/cat "$state_file")
if ! /usr/bin/printf '%s\n' "$managed_anchor" | /usr/bin/grep -Eq '^[A-Za-z0-9_.-]+$'; then
  /usr/bin/printf 'Refusing to clean an invalid managed PF anchor: %s\n' "$managed_anchor" >&2
  exit 1
fi

runtime_anchor="com.apple/$managed_anchor"
anchor_path="/etc/pf.anchors/$managed_anchor"
anchor_backup="$anchor_path.before-nix-darwin"
pf_conf_backup=/etc/pf.conf.before-nix-darwin

# Remove both the current nested anchor and the top-level anchor used by older
# module versions. Loading the main ruleset does not guarantee either is empty.
/sbin/pfctl -a "$runtime_anchor" -F rules
/sbin/pfctl -a "$managed_anchor" -F rules

# nix-darwin preserves the file that existed before it managed /etc/pf.conf.
# Copy first so a failed validation remains retryable without losing that file.
if [ -e "$pf_conf_backup" ]; then
  /bin/cp -p "$pf_conf_backup" /etc/pf.conf
else
  /usr/bin/install -o root -g wheel -m 0644 "$default_pf_conf" /etc/pf.conf
fi

if [ -e "$anchor_backup" ]; then
  /bin/mv -f "$anchor_backup" "$anchor_path"
fi

/sbin/pfctl -q -nf /etc/pf.conf
/sbin/pfctl -q -f /etc/pf.conf

# Release only the reference obtained by load-boot-rules. If another service
# owns a PF reference, PF remains enabled.
if [ -f "$token_file" ]; then
  enable_token=$(/bin/cat "$token_file")
  if ! /usr/bin/printf '%s\n' "$enable_token" | /usr/bin/grep -Eq '^[0-9]+$'; then
    /usr/bin/printf '%s\n' 'Refusing to release an invalid PF enable token' >&2
    exit 1
  fi

  /sbin/pfctl -X "$enable_token"
  /bin/rm -f "$token_file"
fi

/bin/rm -f "$pf_conf_backup"
/usr/bin/find /var/log -maxdepth 1 -type f \
  \( -name 'pf-tailscale.log' -o -name 'pf-tailscale.log.[0-9]*' \) -delete
/bin/rm -f "$state_file"
