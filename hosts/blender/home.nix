{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/home/base
    ../../modules/home/applications.nix
    ../../modules/home/discord.nix
    ../../modules/home/ghostty.nix
    ../../modules/home/firefox.nix
    ../../modules/home/zed.nix
    ../../modules/home/vscode.nix
    ../../modules/home/winbox.nix
    ../../modules/home/niri
    ../../modules/home/noctalia
  ];

  # Shared shell initialization already runs fastfetch for login shells.
  programs.zsh.initContent = lib.mkAfter ''
    if [[ -o interactive && ! -o login && -t 1 && -z ''${SSH_CONNECTION:-} && -z ''${CI:-} ]]; then
      ${pkgs.fastfetch}/bin/fastfetch
    fi
  '';

  dotfiles.niri.extraInputConfig = ''
    mouse {
        natural-scroll
    }
  '';

  dotfiles.niri.extraConfig = ''
    output "Dell Inc. DELL U2725QE 8DNMGF4" {
        mode "3840x2160@119.999"
        scale 1.25
    }
  '';

  # Ghostty uses the last value when a scalar setting appears more than once.
  xdg.configFile."ghostty/config".text = lib.mkAfter ''
    font-size = 12
    background-opacity = 0.85
  '';

  programs.git.signing.key = "5F73329AB4C0EE88F426212A9BD61B25CBCCEBF4!";

  programs.zed-editor.userSettings.theme = lib.mkForce {
    mode = "system";
    light = "Catppuccin Latte - No Italics";
    dark = "Catppuccin Mocha - No Italics";
  };

  programs.firefox.profiles.default.settings."media.hardware-video-decoding.force-enabled" = true;
}
