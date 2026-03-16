{ ... }:

{
  programs.starship = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;

    settings = {
      format = builtins.concatStringsSep "" [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_commit"
        "$git_status"
        "$package"
        "$nix_shell"
        "$golang"
        "$rust"
        "$python"
        "$nodejs"
        "$c"
        "$lua"
        "$java"
        "$ruby"
        "$swift"
        "$terraform"
        "$kubernetes"

        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      add_newline = true;
      scan_timeout = 30;
      command_timeout = 1000;

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vicmd_symbol = "[❮](bold green)";
      };

      username = {
        show_always = false;
        format = "[$user]($style)@";
      };

      hostname = {
        ssh_only = true;
        format = "[$hostname]($style):";
      };

      directory = {
        symbol = "󰉋 ";
        truncation_length = 3;
        truncation_symbol = "…/";
      };

      git_branch = {
        symbol = "󰘬 ";
        truncation_length = 20;
      };

      git_commit = {
        commit_hash_length = 7;
        tag_symbol = "󰓿 ";
      };

      git_status = {
        conflicted = "=";
        ahead = "⇡";
        behind = "⇣";
        diverged = "⇕";
        untracked = "?";
        stashed = "$";
        modified = "!";
        staged = "+";
        renamed = "»";
        deleted = "✘";
      };

      package.symbol = "󰏓 ";

      cmd_duration = {
        min_time = 2000;
        symbol = "󰔞 ";
        format = "[$duration]($style) ";
      };

      golang.symbol = "󰟓 ";
      rust.symbol = "󱘗 ";
      python.symbol = "󰌠 ";
      nodejs.symbol = "󰎙 ";
      nix_shell.symbol = "󱄅 ";
      c.symbol = "󰙱 ";
      lua.symbol = "󰢱 ";
      java.symbol = "󰬷 ";
      ruby.symbol = "󰴭 ";
      swift.symbol = "󰛥 ";
      terraform.symbol = "󱁢 ";

      kubernetes = {
        disabled = false;
        symbol = "☸ ";
        format = "[$symbol$context( \\($namespace\\))]($style) ";
      };

      docker_context.disabled = true;
    };
  };
}
