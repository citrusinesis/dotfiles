{ inputs, lib, ... }:
{
  imports = [
    ./core.nix
    ./identity.nix
    inputs.nix-index-database.homeModules.default
    ./theme.nix
    ./atuin.nix
    ./bat.nix
    ./btop.nix
    ./eza.nix
    ./fd.nix
    ./packages.nix
    ./ripgrep.nix
    ./ssh.nix
    ./yazi.nix
    ./zsh.nix
    ./starship.nix
    ./fzf.nix
    ./tmux.nix
    ./zoxide.nix
    ./languages
    ./nixvim
    ./direnv.nix
    ./git.nix
    ./gpg.nix
    ./agents
    ./kubernetes.nix
    ./teleport.nix
  ];

  options.dotfiles.casks = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Homebrew casks that nix-darwin installs for this Home's applications.";
  };
}
