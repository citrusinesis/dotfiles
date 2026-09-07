{ pkgs }:
pkgs.writeShellApplication {
  name = "home-manager-backup";
  runtimeInputs = [ pkgs.coreutils ];
  text = ''
    if [ "$#" -ne 1 ]; then
      echo "usage: home-manager-backup PATH" >&2
      exit 64
    fi
    target="$1"
    timestamp="$(date +%Y%m%d-%H%M%S)"
    backup="$target.home-manager-$timestamp.bak"
    suffix=0
    while [ -e "$backup" ] || [ -L "$backup" ]; do
      suffix=$((suffix + 1))
      backup="$target.home-manager-$timestamp.$suffix.bak"
    done
    mv -- "$target" "$backup"
    printf 'Backed up %s to %s\n' "$target" "$backup"
  '';
}
