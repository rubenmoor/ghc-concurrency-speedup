let
  pkgs = import <nixpkgs> { inherit config; };
  easy-hls-src = pkgs.fetchFromGitHub {
    owner = "jkachmar";
    repo = "easy-hls-nix";
    rev = "7c123399ef8a67dc0e505d9cf7f2c7f64f1cd847";
    sha256 = "0402ih4jla62l59g80f21fmgklj7rv0hmn82347qzms18lffbjpx";
  };
  easy-hls = pkgs.callPackage easy-hls-src { ghcVersions = [ "8.10.7" ]; };

  compiler = "ghc8107";
  config = {
    packageOverrides = pkgs: rec {
      haskell = pkgs.haskell // {
        packages = pkgs.haskell.packages // {
          "${compiler}" = pkgs.haskell.packages."${compiler}".override {
            overrides = self: super: {
            };
          };
        };
      };
    };
    allowBroken = false;
  };
  drv = pkgs.haskell.packages."${compiler}".callCabal2nix "ghc-concurrency-speedup" ./. { };
in
  {
    env =
      with pkgs.haskellPackages;
      drv.env.overrideAttrs ( oldAttrs: rec {
        nativeBuildInputs =
          oldAttrs.nativeBuildInputs ++ [
            easy-hls
            cabal-install
            threadscope
          ];
      });
    exec = drv;
  }
