{
  description = "Machine Learning for Digital Verification";

  inputs = {
    toolchains.url = "github:HU90m/lowrisc-toolchains/nix";
  };

  outputs = { self, nixpkgs, toolchains }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    toolchain = toolchains.packages.x86_64-linux.default;
  in {
    devShells.x86_64-linux.default = pkgs.mkShell {
        packages = with pkgs; [
          toolchain
          zlib
          verilator
          python311
          python311Packages.cocotb
          python311Packages.pyzmq
          # Python Code Quality Tools
          python311Packages.flake8
          python311Packages.mypy
        ];
    };
    apps.x86_64-linux.asm2bytes = let
      asm2bytes = pkgs.writeShellApplication {
        name = "asm2bytes";
        runtimeInputs = [ toolchain ];
        text = ''
          ASM_FILE="$1"
          OBJ_FILE="$(mktemp)"
          BYTE_FILE="$2"

          echo "Assembling..."
          riscv32-unknown-elf-as -march=rv32imcb "$ASM_FILE" -o "$OBJ_FILE"
          echo "Extracting bytes..."
          riscv32-unknown-elf-objcopy -O binary --only-section=.text "$OBJ_FILE" "$BYTE_FILE"
        '';
      };
    in {
      type = "app";
      program = "${asm2bytes}/bin/asm2bytes";
    };
  };
}
