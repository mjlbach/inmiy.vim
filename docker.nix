{ pkgs ? import <nixpkgs> {
    system = "x86_64-linux";
    overlays = [
      (import (builtins.fetchTarball {
        url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
      }))
    ];
  }
}:

let
  defaults_nvim = pkgs.fetchFromGitHub {
    owner = "mjlbach";
    repo = "defaults.nvim";
    rev = "47b245bb25c7988ec71a8fe349804207d3a83325";
    sha256 = "1jim2izin71x3cwwhqm3f6n00pwq8krmk6h98ij4553ycqy4ryj1";
  };
  packer_src = pkgs.fetchFromGitHub {
    owner = "wbthomason";
    repo = "packer.nvim";
    rev = "c1aa0c773f764950d5e11efb8cba62d6e1b462fc";
    sha256 = "1j79v0gvp2i6vz8hg7ajyafd69pcwb4xpp9wyvqa122nnmqz1w84";
  };
  packer_minimal = ''
    require('packer').startup(function()
      use 'wbthomason/packer.nvim' -- Package manager
      use 'tpope/vim-fugitive' -- Git commands in nvim
      use 'tpope/vim-rhubarb' -- Fugitive-companion to interact with github
      use 'tpope/vim-commentary' -- "gc" to comment visual regions/lines
      use 'ludovicchabant/vim-gutentags' -- Automatic tags management
      -- UI to select things (files, grep results, open buffers...)
      use { 'nvim-telescope/telescope.nvim', requires = { { 'nvim-lua/popup.nvim' }, { 'nvim-lua/plenary.nvim' } } }
      use 'joshdick/onedark.vim' -- Theme inspired by Atom
      use 'itchyny/lightline.vim' -- Fancier statusline
      -- Add indentation guides even on blank lines
      use 'lukas-reineke/indent-blankline.nvim'
      -- Add git related info in the signs columns and popups
      use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }
      -- Highlight, edit, and navigate code using a fast incremental parsing library
      use 'nvim-treesitter/nvim-treesitter'
      -- Additional textobjects for treesitter
      use 'nvim-treesitter/nvim-treesitter-textobjects'
      use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
      use 'hrsh7th/nvim-compe' -- Autocompletion plugin
      use 'L3MON4D3/LuaSnip' -- Snippets plugin
    end)
  '';
in
pkgs.dockerTools.buildImage {
  name = "neovim-test-container";
  contents = [
    pkgs.git
    pkgs.busybox
    # pkgs.stdenv
    # pkgs.coreutils
    # pkgs.runtimeShell
  ];
  runAsRoot = ''
    #!${pkgs.runtimeShell}
    mkdir -p /.local/share/nvim/site/pack/packer/start/
    ln -s ${packer_src} /.local/share/nvim/site/pack/packer/start/packer.nvim

    export HOME=/
    export GIT_SSL_CAINFO=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

    # cp ${defaults_nvim}/init.lua /init_bootstrap.lua
    # ${pkgs.gnused}/bin/sed -i -n '/end)/q;p' /init_bootstrap.lua
    # echo 'end)' >> /init_bootstrap.lua
    echo "${packer_minimal}" > /init_bootstrap.lua


    ${pkgs.neovim-nightly}/bin/nvim -u /init_bootstrap.lua --headless +'packadd packer.nvim | autocmd User PackerComplete sleep 100m | qall' +'PackerInstall'
  '';
  config = {
    Cmd = [ "${pkgs.neovim-nightly}/bin/nvim" "-u" "${defaults_nvim}/init.lua" ];
    Env =
      [ 
        "GIT_SSL_CAINFO=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
        "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      ];
  };
}

