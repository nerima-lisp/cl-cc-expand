{
  description = "Macroexpansion for the cl-cc Common Lisp compiler";

  inputs = {
    # nixos-unstable, not nixpkgs-unstable: it advances only after the NixOS
    # release tests pass, so it is less likely to land a broken build.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # cl-cc-expand.asd's own :depends-on is ("cl-cc-bootstrap" "cl-cc-type"
    # "cl-cc-vm"), all three already externalized. cl-cc-type and cl-cc-vm
    # each pull in their own transitive closure, so every sibling below is
    # consumed purely as a raw ASDF source tree (`cl.lispDerivation`'s
    # `src`), exactly as cl-cc-cps and cl-cc-type do for cl-cc-ast and
    # cl-weave -- this flake never touches those repositories' own
    # packages/checks outputs, and none of the `flake = false` entries carry
    # `inputs.nixpkgs.follows` (a source-only input has no inputs of its own
    # to redirect).
    #
    # Direct dependency, pinned to its release tag per DEPENDENCY_POLICY.md's
    # "tag, not bare commit" rule. Diffed against cl-cc-bootstrap's current
    # HEAD (821bc1f) before pinning: the only changes since v0.1.0 are
    # docs/CI/metadata, zero src/ changes, so the tag is functionally
    # identical to HEAD.
    cl-cc-bootstrap = {
      url = "github:nerima-lisp/cl-cc-bootstrap/v0.1.0";
      flake = false;
    };

    # Transitive, via cl-cc-type's own :depends-on ("cl-cc-ast"). Pinned to
    # the same v0.2.0 tag cl-cc-type's own flake.nix already builds against,
    # so this is a combination already proven to work rather than an
    # independently-guessed pin.
    cl-cc-ast = {
      url = "github:nerima-lisp/cl-cc-ast/v0.2.0";
      flake = false;
    };

    cl-cc-type = {
      url = "github:nerima-lisp/cl-cc-type/v0.2.0";
      flake = false;
    };

    # cl-cc-vm's :depends-on at its v0.1.0 tag is exactly
    # (:cl-cc-bootstrap :cl-cc-runtime :cl-regex-kit :cl-tty-kit) --
    # verified by reading cl-cc-vm.asd AT that tag rather than at its
    # current HEAD, which has since added a fourth dependency
    # (cl-host-kit, from a later uiop migration) that v0.1.0's source does
    # not use. Pinning the whole transitive closure to the era each
    # dependency's own v0.1.0-generation flake.nix used (cl-cc-runtime
    # v0.1.0, which itself predates cl-log-kit 2.0.0's move off
    # zero-dependency) keeps every pin below internally consistent instead
    # of mixing a v0.1.0 leaf against a newer sibling it was never built or
    # tested against.
    cl-cc-runtime = {
      url = "github:nerima-lisp/cl-cc-runtime/v0.1.0";
      flake = false;
    };

    # cl-cc-runtime v0.1.0's own :depends-on ("cl-log-kit" "cl-process-kit"
    # "cl-json-kit") -- the v1.0.0 generation of each, before cl-log-kit
    # 2.0.0 added cl-date-kit/cl-concurrent-kit/cl-boundary-kit as new
    # runtime deps of its own (see cl-cc-vm's current flake.nix for that
    # later chain; irrelevant here since cl-cc-vm v0.1.0 never reaches it).
    cl-log-kit = {
      url = "github:nerima-lisp/cl-log-kit/v1.0.0";
      flake = false;
    };
    cl-process-kit = {
      url = "github:nerima-lisp/cl-process-kit/v1.0.0";
      flake = false;
    };
    # cl-process-kit v1.0.0 also depends on cl-boundary-kit.  Keep this
    # source input separate so its ASDF registry entry is available while
    # compiling cl-process-kit itself, not only its downstream consumers.
    cl-boundary-kit = {
      url = "github:nerima-lisp/cl-boundary-kit/v0.6.0";
      flake = false;
    };
    cl-json-kit = {
      url = "github:nerima-lisp/cl-json-kit/v1.0.0";
      flake = false;
    };

    # cl-cc-vm v0.1.0's other two direct deps. cl-regex-kit had no tagged
    # release when cl-cc-vm's own flake.nix was last written (it pinned a
    # bare commit); it has one now (v0.2.0), so this follows
    # DEPENDENCY_POLICY.md's tag rule instead of carrying that same bare
    # commit forward.
    cl-regex-kit = {
      url = "github:nerima-lisp/cl-regex-kit/v0.2.0";
      flake = false;
    };
    # cl-regex-kit's own tokenizer dependency.
    cl-parser-kit = {
      url = "github:nerima-lisp/cl-parser-kit/v1.0.1";
      flake = false;
    };
    cl-tty-kit = {
      url = "github:nerima-lisp/cl-tty-kit/v1.0.3";
      flake = false;
    };

    cl-cc-vm = {
      url = "github:nerima-lisp/cl-cc-vm/v0.1.0";
      flake = false;
    };

    # Direct dependency for HOST-KIT:GETENV in src/macros-stdlib.lisp.
    cl-host-kit = {
      url = "github:nerima-lisp/cl-host-kit/v0.2.1";
      flake = false;
    };

    # Test-only: cl-weave is the org's test framework. Pinned to its release
    # tag, which is what every other repository in the org references.
    cl-weave = {
      url = "github:nerima-lisp/cl-weave/v1.1.0";
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
      url = "github:nerima-lisp/cl-nix-forge/v0.4.0";
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
      cl-boundary-kit,
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

      # CI builds and tests only x86_64-linux, matching cl-cc-bootstrap,
      # cl-cc-type and cl-cc-vm (the org's newest siblings as of this
      # extraction). `mkPackageFlake` generates every per-system output from
      # this one list -- packages, checks, apps and devShells alike -- so
      # this is also what `nix develop`/`nix build` resolve against.
      systems = [
        "x86_64-linux"
      ];

      # cl-cc-expand's own suite is ~90 source-derived test files (ported
      # wholesale from the monorepo's packages/expand/tests/ via the
      # cl-cc-type shim pattern), larger than cl-cc-cps's but well short of
      # cl-cc-type's 1200s budget; 300s leaves headroom without adopting
      # cl-cc-type's number wholesale.
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
          };
          boundaryKit = mkDependency {
            lispSystem = "cl-boundary-kit";
            source = cl-boundary-kit;
            asd = "/cl-boundary-kit.asd";
            lispDependencies = [ logKit ];
          };
          processKit = mkDependency {
            lispSystem = "cl-process-kit";
            source = cl-process-kit;
            asd = "/cl-process-kit.asd";
            lispDependencies = [
              boundaryKit
              logKit
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
          regexKit = mkDependency {
            lispSystem = "cl-regex-kit";
            source = cl-regex-kit;
            asd = "/cl-regex-kit.asd";
            lispDependencies = [ parserKit ];
          };
          ttyKit = mkDependency {
            lispSystem = "cl-tty-kit";
            source = cl-tty-kit;
            asd = "/cl-tty-kit.asd";
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

      # No `docs` attribute: like cl-cc-cps, this extraction did not stand
      # up an MkDocs Material site. `docs = null` (the preset's default)
      # omits the docs package and its check entirely rather than failing on
      # a missing docs/mkdocs.yml.

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
          paredit-lint = paredit-cli.lib.${ctx.system}.mkLintCheck {
            inherit (ctx) src;
            name = "cl-cc-expand-paredit-lint";
          };
        };
      };
    };
}
