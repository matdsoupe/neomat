{
  description = "Math's neovim config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    neovim = {
      url = "github:neovim/neovim?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    vim-rescript = { url = "github:rescript-lang/vim-rescript"; flake = false; };
    editorconfig-vim = { url = "github:editorconfig/editorconfig-vim"; flake = false; };
    true-zen = { url = "github:Pocco81/TrueZen.nvim"; flake = false; };
    emmet-vim = { url = "github:mattn/emmet-vim"; flake = false; };
    nvim-ts-rainbow = { url = "github:p00f/nvim-ts-rainbow"; flake = false; };
    codi-vim = { url = "github:metakirby5/codi.vim"; flake = false; };
    vim-surround = { url = "github:tpope/vim-surround"; flake = false; };
    vimtex = { url = "github:lervag/vimtex"; flake = false; };
    direnv-vim = { url = "github:direnv/direnv.vim"; flake = false; };
    ultisnips = { url = "github:SirVer/ultisnips"; flake = false; };
    vim-matchup = { url = "github:andymass/vim-matchup"; flake = false; };
    vim-snippets = { url = "github:honza/vim-snippets"; flake = false; };
    nvim-comment = { url = "github:terrortylor/nvim-comment"; flake = false; };
    neoscroll = { url = "github:karb94/neoscroll.nvim"; flake = false; };
    bullets-vim = { url = "github:dkarter/bullets.vim"; flake = false; };
    telescope-nvim = { url = "github:nvim-telescope/telescope.nvim"; flake = false; };
    vim-highlightedyank = { url = "github:machakann/vim-highlightedyank"; flake = false; };
    nvim-colorizer-lua = { url = "github:norcalli/nvim-colorizer.lua"; flake = false; };
    dashboard-nvim = { url = "github:glepnir/dashboard-nvim"; flake = false; };
    nvim-autopairs = { url = "github:windwp/nvim-autopairs"; flake = false; };
    vim-haskell-module-name = { url = "github:UnkindPartition/vim-hs-module-name"; flake = false; };
    indent-blankline-nvim-lua = { url = "github:lukas-reineke/indent-blankline.nvim"; flake = false; };
    monochrome = { url = "github:kdheepak/monochrome.nvim"; flake = false; };
    neon = { url = "github:rafamadriz/neon"; flake = false; };
    vim-polyglot = { url = "github:sheerun/vim-polyglot"; flake = false; };
    gitsigns-nvim = { url = "github:lewis6991/gitsigns.nvim"; flake = false; };
    nvim-treesitter = { url = "github:nvim-treesitter/nvim-treesitter"; flake = false; };
    nvim-tree-lua = { url = "github:kyazdani42/nvim-tree.lua"; flake = false; };
    galaxyline-nvim = { url = "github:glepnir/galaxyline.nvim"; flake = false; };
    popup-nvim = { url = "github:nvim-lua/popup.nvim"; flake = false; };
    plenary-nvim = { url = "github:nvim-lua/plenary.nvim"; flake = false; };
    nvim-web-devicons = { url = "github:kyazdani42/nvim-web-devicons"; flake = false; };
    vimagit = { url = "github:jreybert/vimagit"; flake = false; };
    nvim-which-key = { url = "github:folke/which-key.nvim"; flake = false; };
    syntastic = { url = "github:vim-syntastic/syntastic"; flake = false; };
    trouble = { url = "github:folke/trouble.nvim"; flake = false; };
    vim-elixir = { url = "github:elixir-editors/vim-elixir"; flake = false; };
    calvera-dark = { url = "github:yashguptaz/calvera-dark.nvim"; flake = false; };
    sonokai = { url = "github:sainnhe/sonokai"; flake = false; };
  };

  outputs = { self, nixpkgs, neovim, ... }@inputs:
  let
    plugins = [
      "vim-rescript"
      "editorconfig-vim"
      "true-zen"
      "emmet-vim"
      "nvim-ts-rainbow"
      "codi-vim"
      "vim-surround"
      "vimtex"
      "direnv-vim"
      "ultisnips"
      "vim-matchup"
      "vim-snippets"
      "nvim-comment"
      "popup-nvim"
      "plenary-nvim"
      "neoscroll"
      "bullets-vim"
      "telescope-nvim"
      "vim-highlightedyank"
      "nvim-colorizer-lua"
      "dashboard-nvim"
      "nvim-autopairs"
      "vim-haskell-module-name"
      "indent-blankline-nvim-lua"
      "monochrome"
      "neon"
      "vim-polyglot"
      "gitsigns-nvim"
      "nvim-treesitter"
      "nvim-tree-lua"
      "galaxyline-nvim"
      "nvim-web-devicons"
      "vimagit"
      "nvim-which-key"
      "syntastic"
      "trouble"
      "vim-elixir"
      "calvera-dark"
      "sonokai"
    ];

    externalOverlay = prev: super: {
      neovim-nightly = neovim.defaultPackage.${prev.system};
    };

    pluginOverlay = prev: super: let
      buildPlug = name: prev.vimUtils.buildVimPluginFrom2Nix {
        pname = name;
        version = "HEAD";
        src = builtins.getAttr name inputs;
      };
    in {
      neovimPlugins = builtins.listToAttrs (map (name: { inherit name; value = buildPlug name; }) plugins);
    };

    allPkgs = lib.mkPkgs {
      inherit nixpkgs;
      cfg = { };
      overlays = [
        pluginOverlay
        externalOverlay
      ];
    };

    lib = import ./lib;

    mkNeovimPkg = pkgs: lib.neovimWrapper {
      inherit pkgs;
      config.vim = {
        viAlias = true;
        vimAlias = true;
        theme.sonokai.enable = true;
        disableArrows = true;
        editor.indentGuide = true;
        trouble.enable = false;
      };
    };
  in {
    apps = lib.withDefaultSystems (sys: {
      nvim = {
        type = "app";
        program = "${self.defaultPackage."${sys}"}/bin/nvim";
      };
    });

    defaultApp = lib.withDefaultSystems (sys: {
      type = "app";
      program = "${self.defaultPackage."${sys}"}/bin/nvim";
    });

    defaultPackage = lib.withDefaultSystems (sys: self.packages."${sys}".copper);

    packages = lib.withDefaultSystems (sys: {
      copper = mkNeovimPkg allPkgs."${sys}";
    });
  };
}
