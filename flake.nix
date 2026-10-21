{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, ... }:
  let
    system = "aarch64-darwin";
    pkgs = import nixpkgs { inherit system; };

    configuration = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        vim
        python3

        # OCaml compiler and tools
        ocaml
        ocamlPackages.findlib
        ocamlPackages.utop
        ocamlPackages.dune_3
        ocamlPackages.merlin
        ocamlPackages.ocp-indent
	neovim
        
        # Build tools
        pkg-config
        gcc
        
        # Optional: Popular OCaml libraries
        ocamlPackages.core
        ocamlPackages.ppx_jane
        ocamlPackages.containers
        
        # Development utilities
        git
        vim
        man-pages
      ];

      nix = {
        settings = {
          experimental-features = "nix-command flakes";
          connect-timeout = 30;
        };
        package = pkgs.nix;
      };

      programs.fish.enable = true;

      # Optionally record the flake revision used for this build
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Read the changelog before changing:
      # $ darwin-rebuild changelog
      system.stateVersion = 6;
    };
  in
  {
    darwinConfigurations."tmps-MacBook-Neo" = nix-darwin.lib.darwinSystem {
      inherit system;
      modules = [ configuration ];
    };
  };
}
