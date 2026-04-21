{
  inputs = {
    # This is pointing to an unstable release.
    # If you prefer a stable release instead, you can this to the latest number shown here: https://nixos.org/download
    # i.e. nixos-24.11
    # Use `nix flake update` to update the flake to the latest revision of the chosen release channel.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, neovim-nightly-overlay, ... }@inputs: {
    nixosConfigurations = {
      "unicorn" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; inherit neovim-nightly-overlay; };

        modules = [ 
          ./hosts/unicorn/configuration.nix 
          ./common/configuration.nix
        ];
      };

      "framework" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; inherit neovim-nightly-overlay; };

        modules = [ 
          ./hosts/framework/configuration.nix 
          ./common/configuration.nix
        ];
      };
    };
  };
}

