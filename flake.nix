{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    confetti.url = "github:Kn4ughty/tadaa";
    quickshell = {
        url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, confetti, ... }@inputs: {
    nixosConfigurations = {
      "unicorn" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };

        modules = [ 
          ./hosts/unicorn/configuration.nix 
          ./common/configuration.nix
        ];
      };

      "framework" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };

        modules = [ 
          ./hosts/framework/configuration.nix 
          ./common/configuration.nix
        ];
      };
    };
  };
}

