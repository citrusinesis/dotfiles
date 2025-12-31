{ ... }:

{
  programs.fd = {
    enable = true;
    hidden = true;
    ignores = [
      ".git/"
      "node_modules/"
      "target/"
      "__pycache__/"
    ];
  };
}
