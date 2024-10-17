{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.systems.url = "github:nix-systems/default";
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.systems.follows = "systems";
  };

  nixConfig = {
    extra-sandbox-paths = [ "/sys" ];
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # devShells.default = pkgs.mkShell { packages = with pkgs;[ bashInteractive gccStdenv mpi cmake mpi.dev ]; };

        packages = rec {
          default = hello;

          hello = with pkgs; stdenv.mkDerivation {
            name = "hello-mpi";

            src = lib.fileset.toSource { root = ./.; fileset = ./.; };

            buildInputs = [ mpi ];

            doCheck = true;

            installFlags = [ "PREFIX=\${out}" ];
          };
        };
      }
    );
}
