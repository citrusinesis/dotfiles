#!/usr/bin/env bash
# nix-darwin can remove the old plist without unloading its GUI-domain job.
# Check launchd's registered path, including after a partially failed activation.
migrateLegacyKeyRemapping() {
  local service="gui/$UID/com.local.KeyRemapping"
  local registered version

  if ! registered="$(/bin/launchctl print "$service" 2>/dev/null)"; then
    return 0
  fi

  if ! printf '%s\n' "$registered" | grep -Eq '^[[:blank:]]*path = /Library/LaunchAgents/com[.]local[.]KeyRemapping[.]plist$'; then
    return 0
  fi

  verboseEcho "Unloading legacy nix-darwin key-remapping agent from $service"
  version="$(/usr/bin/sw_vers --productVersion)"
  if (( ${version%%.*} >= 26 )); then
    run /bin/launchctl bootout --wait "$service"
  else
    run /bin/launchctl bootout "$service" || return
    run sleep 1
  fi
}

migrateLegacyKeyRemapping
