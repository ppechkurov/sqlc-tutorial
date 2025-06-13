{
  description = "Jira flake development environment";

  # Flake inputs
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  # Flake outputs
  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in with pkgs; {
        # Development environment output
        devShells = {
          default = mkShell {
            # The Nix packages provided in the environment
            packages = [
              go_1_24
              golangci-lint
              golangci-lint-langserver
              gopls
              gotools
              direnv
              watchexec
              gnumake
              gotestdox
            ];
          };
        };

        packages.default = buildGo124Module rec {
          pname = "jira";
          version = "0.0.4";
          src = ./.;
          vendorHash = "sha256-qDAQ/doF+BHSLEdrYcOPn1CxogMzlAzs5JTmOa30M4s=";
          nativeBuildInputs = [ installShellFiles ];
          ldflags = [
            "-X github.com/ppechkurov/jira/internal/build.Version=${version}"
            "-X github.com/ppechkurov/jira/internal/build.Commit=${self.rev}"
            "-s"
            "-w"
          ];

          postInstall = ''
            installShellCompletion --cmd ${pname} --zsh <($out/bin/${pname} completion zsh)
          '';
        };
      });
}
