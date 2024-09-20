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

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

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

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    # install script
    # this enables us to deploy the configuration onto a new system using
    # nix run github:koalagang/kudos --no-write-lock-file
    packages.x86_64-linux.my-script = with nixpkgs.legacyPackages.x86_64-linux; stdenv.mkDerivation {
      pname = "install";
      version = "1.0";
      dontConfigure = true;
      dontInstall = true;
      src = ./.;
      buildInputs = [
        git
        coreutils
        diffutils
        mkpasswd
        toybox
      ];
      buildPhase = ''
        mkdir -p $out/bin
        cp install.sh $out/bin/install
        chmod +x $out/bin/install
      '';
    };
    defaultPackage.x86_64-linux = self.packages.x86_64-linux.install;
    apps.x86_64-linux.default = {
      type = "app";
      program = "${self.packages.x86_64-linux.my-script}/bin/install";
    };

    # the actual configuration that is used when running nixos-install or nixos-rebuild
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
