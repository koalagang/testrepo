#  \##|   |
###\\ |   |
#   \\|   \'---'/   Gabriel (@koalagang)
#    \   _'.'O'.'   https://github.com/koalagang
#     | :___   \
#     |  _| :  |
#     | :__,___/
#     |   |
#     |   |
#     |   |
{
  description = "Koala's Unified and Declarative Operating System";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # hyprcursor theme
    # make sure to add `inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default` to your packages
    # and add `env = HYPRCURSOR_THEME,rose-pine-hyprcursor` to hyprland.conf
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
  };

  outputs = inputs@{ nixpkgs, home-manager, self, ... }: {
    packages.x86_64-linux.my-script = with nixpkgs.legacyPackages.x86_64-linux; stdenv.mkDerivation {
      pname = "my-script";
      version = "1.0";

      src = ./.;  # this assumes your script is in the root of the repository

      buildPhase = ''
        mkdir -p $out/bin
        cp myscript.sh $out/bin/myscript  # replace 'myscript.sh' with your script's filename
        chmod +x $out/bin/myscript
      '';

      # optionally, you can define an install phase if needed
    };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.my-script;
    # define a default app to run
    apps.x86_64-linux.default = {
      type = "app";
      program = "${self.packages.x86_64-linux.my-script}/bin/myscript";  # adjust as necessary
    };

    nixosConfigurations = {
      Myla = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.dante = import ./home.nix;
              # pass inputs to home.nix so we can use firefox-addons
              # for programs.firefox.<profile>.extensions
              extraSpecialArgs = { inherit inputs; };
            };
          }
        ];
      };
    };
  };
}
