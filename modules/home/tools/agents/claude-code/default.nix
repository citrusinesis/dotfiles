{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.claude-code = {
    enable = true;
    package = pkgs.llm-agents.claude-code;
    configDir = "${config.home.homeDirectory}/.claude";
    settings = {
      model = "opus";
      modelSettings.claude-opus-5-5.effortLevel = "medium";
      tui = "fullscreen";
      enabledPlugins = {
        "gopls-lsp@claude-plugins-official" = true;
        "rust-analyzer-lsp@claude-plugins-official" = true;
      };
      skipWorkflowUsageWarning = true;
      theme = "dark";
      attribution = {
        commit = "";
        pr = "";
      };
    };
    context = ./CLAUDE.md;
    rulesDir = pkgs.symlinkJoin {
      name = "claude-code-rules";
      paths = [
        ../rules
        ./rules
      ];
    };
    commandsDir = ./commands;

    mcpServers = {
      context7 = {
        type = "stdio";
        command = lib.getExe pkgs.context7-mcp;
      };
      github = {
        type = "http";
        url = "https://api.githubcopilot.com/mcp/";
      };
    };
  };
}
