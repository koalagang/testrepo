{
  description = "My Nix Flake Example";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";  # or a specific version

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.my-script = with nixpkgs.legacyPackages.x86_64-linux; stdenv.mkDerivation {
      pname = "my-script";
      version = "1.0";

      src = ./.;  # This assumes your script is in the root of the repository

      buildPhase = ''
        mkdir -p $out/bin
        cp myscript.sh $out/bin/myscript  # Replace 'myscript.sh' with your script's filename
        chmod +x $out/bin/myscript
      '';

      # Optionally, you can define an install phase if needed
    };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.my-script;

    # Define a default app to run
    apps.x86_64-linux.default = {
      type = "app";
      program = "${self.packages.x86_64-linux.my-script}/bin/myscript";  # Adjust as necessary
    };
  };
}
