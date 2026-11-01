{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    confetti.url = "github:Kn4ughty/tadaa";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lumin = {
      # url = "git+https://github.com/Kn4ughty/Lumin";
      url = "path:/home/d/code/Lumin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland?ref=v0.55.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      confetti,
      ...
    }@inputs:
    {
      nixpkgs.overlays = [ inputs.lumin.overlays.default ];
      nixosConfigurations = {
        "unicorn" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };

          modules = [
            ./common/configuration.nix
            ./hosts/unicorn/configuration.nix
          ];
        };

        "framework" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };

          modules = [
            ./common/configuration.nix
            ./hosts/framework/configuration.nix
          ];
        };
      };
    };
}
