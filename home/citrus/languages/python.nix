{ pkgs, ... }:

{
  home.packages = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.ipython
    pyright
    ruff
    black
    uv
  ];
}
