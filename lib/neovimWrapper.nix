{ pkgs, lib ? pkgs.lib, ... }:

{ config }:
let
  inherit (pkgs) neovimPlugins wrapNeovim fetchFromGitHub;

  vimOptions = lib.evalModules {
    modules = [
      { imports = [../modules]; }
      config 
    ];

    specialArgs = {
      inherit pkgs; 
    };
  };

  vim = vimOptions.config.vim;
in wrapNeovim pkgs.neovim-unwrapped {
  viAlias = true;
  vimAlias = true;
  withNodeJs = true;
  withPython3 = true;
  configure = {
    customRC = vim.configRC;
    packages.myVimPackage = with pkgs.vimPlugins; {
      start = vim.startPlugins;
      opt = vim.optPlugins;
    };
  };
}
