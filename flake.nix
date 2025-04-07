{
  description = "My diploma shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs { inherit system; config.allowUnfree = true;};
          }
        );
    in
    { 
      devShells = forEachSystem ({pkgs}: {
        default = pkgs.mkShell.override {
          # Here I can override some things, like
          # stdenv = pkgs.clangStdenv;
        } {
          packages = with pkgs; [
            typst
          ];

          FONTCONFIG_FILE = pkgs.makeFontsConf {
            fontDirectories = [pkgs.corefonts];
          };
        };
      });
    };
}
