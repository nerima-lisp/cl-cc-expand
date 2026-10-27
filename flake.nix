{
  description = "Macroexpansion for the cl-cc Common Lisp compiler";

  inputs = {
    # nixos-unstable, not nixpkgs-unstable: it advances only after the NixOS
    # release tests pass, so it is less likely to land a broken build.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # These input repositories provide the ASDF source trees used below.
    # Pin commits to keep the dependency graph fixed.
    cl-cc-bootstrap = {
      url = "github:nerima-lisp/cl-cc-bootstrap/027f6c9826010c15789454e69abd2930738b50af";
      flake = false;
    };
    cl-cc-ast = {
      url = "github:nerima-lisp/cl-cc-ast/a45c5acecfccb91a43f6a04251e8a5d6ec3d3213";
      flake = false;
    };

    cl-cc-type = {
      url = "github:nerima-lisp/cl-cc-type/ff2e742911b4b193457a75208b7b9ad6b06ab23a";
      flake = false;
    };

    cl-cc-runtime = {
      url = "github:nerima-lisp/cl-cc-runtime/d23ea44512b162def39ec981426c4c8e1af4df84";
      flake = false;
    };

    cl-log-kit = {
      url = "github:nerima-lisp/cl-log-kit/v2.2.0";
      flake = false;
    };
    cl-process-kit = {
      url = "github:nerima-lisp/cl-process-kit/v3.4.0";
      flake = false;
    };
    cl-codec-kit = {
      url = "github:nerima-lisp/cl-codec-kit/v0.6.0";
      flake = false;
    };
    # Keep this input separate so cl-process-kit can resolve cl-boundary-kit
    # from its ASDF registry while it compiles.
    cl-boundary-kit = {
      url = "github:nerima-lisp/cl-boundary-kit/v2.3.0";
      flake = false;
    };
    cl-date-kit = {
      url = "github:nerima-lisp/cl-date-kit/v1.1.1";
      flake = false;
    };
    cl-concurrent-kit = {
      url = "github:nerima-lisp/cl-concurrent-kit/v0.6.1";
      flake = false;
    };
    cl-json-kit = {
      url = "github:nerima-lisp/cl-json-kit/v1.2.0";
      flake = false;
    };

    cl-regex-kit = {
      url = "github:nerima-lisp/cl-regex-kit/v2.2.0";
      flake = false;
    };
    # cl-regex-kit's own tokenizer dependency.
    cl-parser-kit = {
      url = "github:nerima-lisp/cl-parser-kit/v1.1.1";
      flake = false;
    };
    cl-tty-kit = {
      url = "github:nerima-lisp/cl-tty-kit/v1.6.1";
      flake = false;
    };

    cl-cc-vm = {
      url = "github:nerima-lisp/cl-cc-vm/ddc3e7440eec0927ffd0ec307aa23c5b66e2050d";
      flake = false;
    };

    # Direct dependency for HOST-KIT:GETENV in src/macros-stdlib.lisp.
    cl-host-kit = {
      url = "github:nerima-lisp/cl-host-kit/v0.3.1";
      flake = false;
    };

    # Test-only: cl-weave is the org's test framework. Pinned to its release
    # tag, which is what every other repository in the org references.
    cl-weave = {
      url = "github:nerima-lisp/cl-weave/v1.4.0";
      flake = false;
    };

    # The org flake preset. Everything this file would otherwise spell out
    # by hand -- `.asd` version extraction, `forAllSystems`, the treefmt
    # eval wired to both `formatter` and `checks.formatting`, the
    # run-tests.lisp gate, the `apps.test`/`apps.default` pair, the devShell
    # and the overlay -- is one `mkPackageFlake` call below. Pinned to a
    # release TAG: a bare `github:nerima-lisp/cl-nix-forge` follows that
    # repository's default branch and would change this build without
    # warning.
    cl-nix-forge = {
      url = "github:nerima-lisp/cl-nix-forge/950a8224940539a97c112a6b872f0ae5b6c115db";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Structure-editing lint gate for Lisp sources, wired the same way
    # cl-cc-type and cl-cc-cps wire it: `paredit-cli.lib.${system}.
    # mkLintCheck` as a `checks.paredit-lint` entry, so a logic-bug lint
    # finding fails `nix flake check` instead of staying an ad hoc local
    # invocation. Pinned to its latest release tag.
    paredit-cli = {
      url = "github:takeokunn/paredit-cli/v1.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      cl-cc-bootstrap,
      cl-cc-ast,
      cl-cc-type,
      cl-cc-runtime,
      cl-log-kit,
      cl-process-kit,
      cl-codec-kit,
      cl-boundary-kit,
      cl-date-kit,
      cl-concurrent-kit,
      cl-json-kit,
      cl-regex-kit,
      cl-parser-kit,
      cl-tty-kit,
      cl-cc-vm,
      cl-host-kit,
      cl-weave,
      cl-nix-forge,
      paredit-cli,
      treefmt-nix,
    }:
    let
      lib = nixpkgs.lib;

      # The package, checks, apps, and dev shell are declared only for
      # x86_64-linux, which is the CI target.
      systems = [ "x86_64-linux" ];

      # cl-cc-expand's suite is ported from the monorepo's
      # packages/expand/tests/ via cl-cc-type's shim pattern. It is larger
      # than cl-cc-cps's but well short of cl-cc-type's 1200s budget; 300s
      # leaves headroom without adopting cl-cc-type's budget wholesale.
      testTimeout = 300;
    in
    cl-nix-forge.lib.${builtins.head systems}.mkPackageFlake {
      inherit
        self
        systems
        nixpkgs
        ;
      pname = "cl-cc-expand";

      # Single source of truth for the package version: the `:version` form
      # in cl-cc-expand.asd.
      asd = ./cl-cc-expand.asd;

      # Required, and it must be a path literal rather than `self`: a
      # flake's `self` is string-like and `lib.fileset` refuses it.
      root = ./.;
      sourceInclude = [
        ./t/export-surface.txt
        ./CHANGELOG.md
      ];

      meta = {
        description = "Macroexpansion subsystem (macro-env, defmacro, macroexpand, lambda-list, LOOP) for cl-cc, extracted from the monorepo";
        homepage = "https://github.com/nerima-lisp/cl-cc-expand";
        license = lib.licenses.mit;
      };

      # Every raw source derivation carries the dependencies required to
      # compile that source.  Listing only the final transitive closure here
      # made cl-cc-runtime build without cl-log-kit in its ASDF registry.
      lispDependencies =
        ctx:
        let
          mkDependency =
            {
              lispSystem,
              source,
              asd,
              lispDependencies ? [ ],
            }:
            ctx.cl.lispDerivation {
              inherit lispSystem lispDependencies;
              version = ctx.cl.fromAsdSystem (source + asd);
              src = source;
            };
          bootstrap = mkDependency {
            lispSystem = "cl-cc-bootstrap";
            source = cl-cc-bootstrap;
            asd = "/cl-cc-bootstrap.asd";
          };
          ast = mkDependency {
            lispSystem = "cl-cc-ast";
            source = cl-cc-ast;
            asd = "/cl-cc-ast.asd";
          };
          type = mkDependency {
            lispSystem = "cl-cc-type";
            source = cl-cc-type;
            asd = "/cl-cc-type.asd";
            lispDependencies = [ ast ];
          };
          logKit = mkDependency {
            lispSystem = "cl-log-kit";
            source = cl-log-kit;
            asd = "/cl-log-kit.asd";
            lispDependencies = [
              dateKit
              concurrentKit
              hostKit
            ];
          };
          boundaryKit = mkDependency {
            lispSystem = "cl-boundary-kit";
            source = cl-boundary-kit;
            asd = "/cl-boundary-kit.asd";
            lispDependencies = [ hostKit ];
          };
          processKit = mkDependency {
            lispSystem = "cl-process-kit";
            source = cl-process-kit;
            asd = "/cl-process-kit.asd";
            lispDependencies = [
              boundaryKit
              logKit
              codecKit
              concurrentKit
            ];
          };
          jsonKit = mkDependency {
            lispSystem = "cl-json-kit";
            source = cl-json-kit;
            asd = "/cl-json-kit.asd";
          };
          runtime = mkDependency {
            lispSystem = "cl-cc-runtime";
            source = cl-cc-runtime;
            asd = "/cl-cc-runtime.asd";
            lispDependencies = [
              logKit
              processKit
              jsonKit
            ];
          };
          parserKit = mkDependency {
            lispSystem = "cl-parser-kit";
            source = cl-parser-kit;
            asd = "/cl-parser-kit.asd";
          };
          codecKit = mkDependency {
            lispSystem = "cl-codec-kit";
            source = cl-codec-kit;
            asd = "/cl-codec-kit.asd";
          };
          dateKit = mkDependency {
            lispSystem = "cl-date-kit";
            source = cl-date-kit;
            asd = "/cl-date-kit.asd";
          };
          concurrentKit = mkDependency {
            lispSystem = "cl-concurrent-kit";
            source = cl-concurrent-kit;
            asd = "/cl-concurrent-kit.asd";
            lispDependencies = [
              boundaryKit
              dateKit
            ];
          };
          regexKit = mkDependency {
            lispSystem = "cl-regex-kit";
            source = cl-regex-kit;
            asd = "/cl-regex-kit.asd";
            lispDependencies = [
              parserKit
              concurrentKit
            ];
          };
          ttyKit = mkDependency {
            lispSystem = "cl-tty-kit";
            source = cl-tty-kit;
            asd = "/cl-tty-kit.asd";
            lispDependencies = [
              codecKit
              concurrentKit
            ];
          };
          vm = mkDependency {
            lispSystem = "cl-cc-vm";
            source = cl-cc-vm;
            asd = "/cl-cc-vm.asd";
            lispDependencies = [
              bootstrap
              runtime
              regexKit
              ttyKit
            ];
          };
          hostKit = mkDependency {
            lispSystem = "cl-host-kit";
            source = cl-host-kit;
            asd = "/cl-host-kit.asd";
          };
        in
        [
          bootstrap
          type
          vm
          hostKit
        ];
      lispCheckDependencies = ctx: [
        (ctx.cl.lispDerivation {
          lispSystem = "cl-weave";
          version = ctx.cl.fromAsdSystem (cl-weave + "/cl-weave.asd");
          src = cl-weave;
        })
      ];

      # `checks.default` and `apps.test` are both run-tests.lisp, driven
      # from this one number, so the command a contributor runs by hand
      # (`nix develop`, then `sbcl --script run-tests.lisp`) and the gate CI
      # runs cannot drift apart.
      timeoutSeconds = testTimeout;

      # ONE treefmt evaluation drives `nix fmt` and the `checks.formatting`
      # gate, so the formatter and the CI gate can never disagree about what
      # "formatted" means. Scope stays the preset's Nix-only default:
      # nixfmt is a low-diff, zero-footgun formatter, whereas a YAML
      # formatter mangles the GitHub Actions `on:` key.
      treefmt.evalModule = treefmt-nix.lib.evalModule;

      # Granularity lives here, NOT in extra GitHub Actions jobs: `nix flake
      # check` evaluates each attribute as its own derivation, in parallel,
      # with build caching.
      extraOutputs = ctx: {
        checks = {
          feature-lint = ctx.cl.mkFeatureLintCheck {
            src = ./.;
            featureDefinitions = "nix/feature-dependencies.sexp";
            glossary = "docs/src/reference/glossary.md";
            glossaryHeadingPrefix = "## ";
            exportSurface = "t/export-surface.txt";
            mode = "strict";
            legacyInternalRefs = "t/legacy-internal-refs.sexp";
            forbiddenNames = [
              "phases"
              "misc"
              "utils"
              "helpers"
            ];
            numberedPrefixes = [
              "FR-"
              "W"
            ];
            packagePrefix = "cl-cc/expand/";
            infraSuffix = "/infra";
          };
          orphan-tests = ctx.cl.mkOrphanTestCheck {
            src = ./.;
            testRoots = [ "t" ];
            testSystems = [ "cl-cc-expand/test" ];
          };
          paredit-lint = paredit-cli.lib.${ctx.system}.mkLintCheck {
            inherit (ctx) src;
            name = "cl-cc-expand-paredit-lint";
          };
        };
      };
    };
}
