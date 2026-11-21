{ pkgs, ... }:

{
  imports = [
    ./claude-code
    ./codex
    ./paseo.nix
  ];

  home.packages = with pkgs.llm-agents; [
    pi
  ];

  programs.opencode = {
    enable = true;
    package = pkgs.llm-agents.opencode;
  };
}
