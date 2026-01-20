{ ... }:

{
  environment.shellAliases = {
    ls = "ls --color=auto";
    ll = "ls -la";
    grep = "grep --color=auto";
    g = "git";
    vi = "vim";
  };

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERM = "xterm-256color";
  };
}
