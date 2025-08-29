{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # home-manager.url = "github:nix-community/home-manager";

    # home-manager nixpkgs follows main nixpkgs
    # this can slightly affect reproducibility, but it can dramatically reduce download sizes
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, ... }@inputs:
  let
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  in
  {
    nixosConfiguration.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
      ];
    };
  };
}
