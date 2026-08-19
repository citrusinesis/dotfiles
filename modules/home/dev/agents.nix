{ pkgs, ... }:

{
  home.packages = with pkgs.llm-agents; [
    claude-code
    codex
    pi
  ];

  programs.opencode = {
    enable = true;
    package = pkgs.llm-agents.opencode;
  };
}
