{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.systems.url = "github:nix-systems/default";
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.systems.follows = "systems";
  };

  nixConfig = {
    # extra-sandbox-paths = [ "/sys/devices/system/cpu/cpu0/topology" ];
    # extra-sandbox-paths = [ "/sys/devices/system/cpu" ];
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

          mpiBwrapped = with pkgs; stdenv.mkDerivation {
            name = "mpi-bwrapped";

            phases = [ "buildPhase" ];

            nativeBuildInputs = [ makeShellWrapper ];

            buildInputs = [ mpi bubblewrap ];

            buildPhase = ''
              install -d $out/root/{proc,dev,build,nix/store,sys/class/net}
              for i in {0..1}
              do
              install -d $out/root/sys/devices/system/cpu/cpu$i/topology
              echo $i > $out/root/sys/devices/system/cpu/cpu$i/topology/core_cpus
              done
              echo '0-1' > $out/root/sys/devices/system/cpu/possible
              # echo '0-1' > $out/root/sys/devices/system/cpu/online
              # echo '0-1' > $out/root/sys/devices/system/cpu/present
              makeWrapper "${bubblewrap}/bin/bwrap" "$out/bin/mpirun" --add-flags "--bind $out/root / --bind /build /build --proc /proc --dev /dev --bind /nix/store /nix/store ${mpi}/bin/mpirun --prefix ${mpi}"
            '';
          };

          hello = with pkgs; stdenv.mkDerivation {
            name = "hello-mpi";

            src = lib.fileset.toSource { root = ./hello; fileset = ./hello; };

            # nativeBuildInputs = [ mpiBwrapped ];

            buildInputs = [ mpi ];

            doCheck = true;

            # nativeCheckInputs = [ mpiBwrapped ];

            installFlags = [ "PREFIX=\${out}" ];
          };
        };
      }
    );
}
