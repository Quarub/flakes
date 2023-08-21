{
  description = "Basic difftesting python environment";

  inputs = {
    quarub_flakes.url = "github:quarub/flakes";
  };

  outputs = { self, nixpkgs, quarub_flakes }:
  let 
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };

    pythonEnv = with quarub_flakes.packages.x86_64-linux;
      (pkgs.python311.withPackages (ps: with ps; [
      program-markers
      static-globals
      ccbuilder_0_1_0b0
      diopter_0_0_24

    ])).override( args: { ignoreCollisions = true; });

  in
  {

    devShells.x86_64-linux.default = pkgs.mkShell {
      hardeningDisable = [ "all" ];
      buildInputs = 
      [
        pythonEnv
      ];
    };
  };
}
