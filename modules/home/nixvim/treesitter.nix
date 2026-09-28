{ config, ... }:

{
  programs.nixvim.plugins.treesitter = {
    enable = true;
    folding.enable = true;
    highlight.enable = true;
    indent.enable = true;
    grammarPackages = with config.programs.nixvim.plugins.treesitter.package.builtGrammars; [
      bash
      c
      cpp
      diff
      html
      javascript
      jsdoc
      go
      gomod
      gosum
      gowork
      json
      latex
      lua
      luadoc
      luap
      markdown
      markdown_inline
      ninja
      nix
      python
      query
      regex
      ron
      rst
      rust
      toml
      tsx
      typst
      typescript
      vim
      vimdoc
      yaml
    ];
  };
}
