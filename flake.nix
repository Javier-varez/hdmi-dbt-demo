{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      fhs = pkgs.buildFHSUserEnv {
        name = "fhs-shell";

        targetPkgs = pkgs: [
          pkgs.go
          pkgs.ninja
        ];
        runScript = "nu";
      };
    in
    {
      devShells.${system}.default = fhs.env;
    };
}
