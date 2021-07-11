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
  src = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/mjlbach/defaults.nvim/master/init.lua";
    sha256 = "04isz6vi8xvwzr2nvx35gifk2ipidhvl97zn0m9jv0iism3y61wi";
  };
  packer_src = pkgs.fetchFromGitHub {
    owner = "wbthomason";
    repo = "packer.nvim";
    rev = "c1aa0c773f764950d5e11efb8cba62d6e1b462fc";
    sha256 = "1j79v0gvp2i6vz8hg7ajyafd69pcwb4xpp9wyvqa122nnmqz1w84";
  };
in
pkgs.dockerTools.buildImage {
  name = "neovim-test-container";
  contents = [
    pkgs.git
    pkgs.dash
  ];
  runAsRoot = ''
    #!${pkgs.runtimeShell}
    mkdir -p /.local/share/nvim/site/pack/packer/start/
    ln -s ${packer_src} /.local/share/nvim/site/pack/packer/start/packer.nvim
    ln -s ${pkgs.stdenv}/bin/sh /bin/sh 
  '';
  config = {
    Cmd = [ "${pkgs.neovim-nightly}/bin/nvim" "-u" "${src}" ];
  };
}

