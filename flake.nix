


{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    antigravity-cli = {
      url = "github:JesManLabs/antigravity-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, antigravity-cli }:

    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {

      packages.${system} = {
        hello = pkgs.hello;
        antigravity-cli = antigravity-cli.packages.${system}.default;
        default = pkgs.hello;
      };

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          ({ config, ... }: {
            environment.systemPackages = [
              antigravity-cli.packages.${system}.default
            ];
          })
        ];
      };

    };
}









# Default Nix flakes Init Config

/*

{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

  };
}
*/

