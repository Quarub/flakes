{
  description = "A flake for some of my compiler testing tools";

  outputs = { self, nixpkgs }: 
  let
    pkgs = import nixpkgs {system = "x86_64-linux";};

  in
  rec {
    packages.x86_64-linux.ccbuilder_0_0_11 = pkgs.python311.pkgs.buildPythonPackage rec {
      pname = "ccbuilder";
      version = "0.0.11";

      format = "pyproject";

      src = pkgs.python311.pkgs.fetchPypi {
        inherit pname version;
        sha256 = "sha256-K1lVVbwOLjpUQhosrMsyFrcQnHG1pcYMhSPkrguRZ0Q=";
      };

      buildInputs = [ pkgs.python311.pkgs.setuptools ];

      doCheck = false;
    };

    packages.x86_64-linux.ccbuilder_0_1_0b0 = pkgs.python311.pkgs.buildPythonPackage rec {
      pname = "ccbuilder";
      version = "0.1.0b0";

      format = "pyproject";

      src = pkgs.python311.pkgs.fetchPypi {
        inherit pname version;
        sha256 = "sha256-Di6Rz+u5WyNFlJCVAMmihlset55OGFJHXbip7a580i8=";
      };

      buildInputs = [ pkgs.python311.pkgs.setuptools packages.x86_64-linux.diopter_0_0_24  ];

      doCheck = false;
    };

    packages.x86_64-linux.diopter_0_0_24 = pkgs.python311.pkgs.buildPythonPackage rec {
      pname = "diopter";
      version = "0.0.24";

      format = "pyproject";

      src = pkgs.python311.pkgs.fetchPypi {
        inherit pname version;
        sha256 = "sha256-4idCsYj2XNhR+V6fMQn/Cdrfhn/dil4Afjm64wHH5dQ=";
      };

      buildInputs = [ pkgs.python311.pkgs.setuptools ];
      doCheck = false;
    };

    packages.x86_64-linux.program-markers = pkgs.python311.pkgs.buildPythonPackage rec {
      pname = "program-markers";
      version = "0.5.2";

      format = "pyproject";

      # Fetch the source code from GitHub.
      src = pkgs.fetchFromGitHub {
        owner = "DeadCodeProductions";
        repo = "program-markers";
        rev = "v${version}";
        sha256 = "sha256-6LXpyXnFQbIvKYJIzTOc6g5x2reWjq4SCyQzdvXOz/Q=";
      };

      buildInputs = [ 
        pkgs.python311.pkgs.setuptools 
      ];

      nativeBuildInputs = [
        pkgs.cmake
        pkgs.clang_15
      ];

      propagatedBuildInputs = [
        packages.x86_64-linux.diopter_0_0_24
        pkgs.llvmPackages_15.libllvm.dev
        pkgs.llvmPackages_15.libclang.dev
      ];

      buildPhase = ''
        # cmake runs the cmakeConfigure phase so we are already 
        # in the build directory.
        make
        cd ..
        cp build/bin/program-markers python_src/program_markers
        cp setup.py.in setup.py
        sed -i "s~THIS_DIR~$(pwd)~g" setup.py
        pipBuildPhase
      '';

      LLVM_DIR = pkgs.llvmPackages_15.libllvm.dev;
      Clang_DIR = pkgs.llvmPackages_15.libclang.dev;

      nativeCheckInputs = [ pkgs.python3.pkgs.pytest ];

      checkPhase = ''
        pytest
      '';

      doCheck = true;
    };

    
    packages.x86_64-linux.static-globals = packages.x86_64-linux.program-markers.override (rec {
      pname = "static-globals";
      version = "0.0.2";
      src = pkgs.fetchFromGitHub {
        owner = "DeadCodeProductions";
        repo = "static-globals";
        rev = "v${version}";
        sha256 = "sha256-HntkJxiid7Jn0MXSR3sgslMOpNJbtj9WRKy3WW0xig4=";
      };

      buildPhase = ''
        make
        cd ..
        cp build/bin/make-globals-static python_src/static_globals
        cp setup.py.in setup.py
        sed -i "s~THIS_DIR~$(pwd)~g" setup.py
        pipBuildPhase
      '';
    });

    templates.python-difftesting = {
      description = "Template for a python with diopter etc.";
      path = ./diff;
    };

  };


}
