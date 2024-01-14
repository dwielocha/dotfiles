{ config, pkgs, lib, username, ... }:
let
  extensions = [
    amiralizadeh9480.laravel-extra-intellisense
    bbenoist.nix
    biomejs.biome
    bmewburn.vscode-intelephense-client
    catppuccin.catppuccin-vsc
    dbaeumer.vscode-eslin
    dracula-theme.theme-dracula
    esbenp.prettier-vscode
    github.copilot
    github.copilot-chat
    jnoortheen.nix-ide
    mohsen1.prettify-json
    ms-vscode.vscode-typescript-next
    oven.bun-vscode
    patbenatar.advanced-new-file
    phiter.phpstorm-snippets
    sleistner.vscode-fileutils
  ];
in
{
  options = {
    vscode.extensions = lib.mkOption { default = [ ]; };
    vscode.user = lib.mkOption { }; # <- Must be supplied
    vscode.homeDir = lib.mkOption { }; # <- Must be supplied
    nixpkgs.latestPackages = lib.mkOption { default = [ ]; };
  };

  config = {
    ###
    # DIRTY HACK
    # This will fetch latest packages on each rebuild, whatever channel you are at
    nixpkgs.overlays = [
      (self: super:
        let latestPkgs = import (fetchTarball https://github.com/nixos/nixpkgs-channels/archive/nixpkgs-unstable.tar.gz) {
          config.allowUnfree = true;
        };
        in lib.genAttrs config.nixpkgs.latestPackages (pkg: latestPkgs."${pkg}")

      )
    ];
    # END DIRTY HACK
    ###

    environment.systemPackages = [ pkgs.vscode ];

    system.activationScripts.fix-vscode-extensions = {
      text = ''
        EXT_DIR=/home/${username}/.vscode/extensions
        mkdir -p $EXT_DIR
        chown ${username}:users $EXT_DIR
        for x in ${lib.concatMapStringsSep " " toString extensions}; do
            ln -sf $x/share/vscode/extensions/* $EXT_DIR/
        done
        chown -R ${username}:users $EXT_DIR
      '';
      deps = [ ];
    };
  };
}
