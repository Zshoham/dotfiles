# nix flake check: everything builds, neovim starts cleanly, and the shells
# have the toolchains they're for.
{
  pkgs,
  packages,
  nixosConfigurations,
}:

let
  inherit (pkgs) lib runCommand;
  inherit (packages) environments;

  # the rootfs of an environment's FHS shell, checked without bubblewrap
  # (which doesn't run in the build sandbox)
  rootfs = name: environments.${name}.shell.fhsenv;

  shellNames = env: map (env: env.shell.name) (lib.filter (env: env.needsFhs) env.closure);
  hostShellNames = env: map (pkg: pkg.name) (lib.filter (pkg: pkg ? fhsenv) env.hostPackages);

  nvimTest = pkgs.writeText "nvim-test.lua" ''
    vim.defer_fn(function()
      local errors = {}
      local function check(ok, what)
        if not ok then table.insert(errors, what) end
      end
      check(package.loaded["lazyvim"] ~= nil, "LazyVim is not loaded")
      for _, plugin in ipairs(require("lazy").plugins()) do
        check(plugin.dir and vim.uv.fs_stat(plugin.dir), "missing plugin " .. plugin.name)
      end
      for _, lang in ipairs({ "lua", "python", "bash", "bitbake", "c" }) do
        check(pcall(vim.treesitter.language.add, lang), "no tree-sitter parser for " .. lang)
      end
      for _, tool in ipairs({ "lua-language-server", "clangd", "ruff", "ty", "stylua", "bash-language-server" }) do
        check(vim.fn.executable(tool) == 1, tool .. " is not on PATH")
      end
      local messages = vim.api.nvim_exec2("messages", { output = true }).output
      check(messages == "", "startup messages:\n" .. messages)
      io.stdout:write(table.concat(errors, "\n"))
      vim.cmd(#errors == 0 and "qa!" or "cq!")
    end, 1000)
  '';
in
# every environment's package (its shell or its host packages)
lib.mapAttrs' (name: env: lib.nameValuePair "environment-${name}" env.package) environments
# every container
// lib.mapAttrs' (
  name: system: lib.nameValuePair "container-${name}" system.config.system.build.toplevel
) nixosConfigurations
// {
  neovim = runCommand "neovim-starts" { } ''
    export HOME=$(mktemp -d)
    cd $HOME
    if ! timeout 60 ${packages.programs.neovim}/bin/nvim --headless -c 'luafile ${nvimTest}' > out 2>&1; then
      cat out
      exit 1
    fi
    touch $out
  '';

  # yocto's toolchain wins in the shells including it
  yocto-toolchain = runCommand "yocto-toolchain" { } ''
    for env in ${rootfs "yocto"} ${rootfs "workbox"}; do
      $env/usr/bin/gcc --version | grep -q ' 13\.' || { echo "$env: gcc is not 13"; exit 1; }
      $env/usr/bin/python3 --version | grep -q ' 3\.12\.' || { echo "$env: python is not 3.12"; exit 1; }
      $env/usr/bin/python3 -c 'import git, jinja2, pexpect, subunit'
      for tool in chrpath diffstat lz4c zstd file gawk; do
        test -x $env/usr/bin/$tool || { echo "$env: no $tool"; exit 1; }
      done
    done
    touch $out
  '';

  conda-tools = runCommand "conda-tools" { } ''
    for env in ${rootfs "conda"} ${rootfs "workbox"}; do
      for tool in micromamba pixi; do
        test -x $env/usr/bin/$tool || { echo "$env: no $tool"; exit 1; }
      done
      test -e $env/usr/lib64/libcrypt.so.1 || { echo "$env: no libcrypt.so.1"; exit 1; }
    done
    touch $out
  '';

  # an environment installs the shells of everything in it needing them
  host-shells =
    let
      wrong = lib.filter (env: shellNames env != hostShellNames env) (lib.attrValues environments);
    in
    assert lib.assertMsg (wrong == [ ]) (
      "wrong shells on the host: "
      + lib.concatMapStringsSep ", " (
        env: "${env.name} has [${toString (hostShellNames env)}], not [${toString (shellNames env)}]"
      ) wrong
    );
    assert lib.assertMsg (
      shellNames environments.workbox == [
        "yocto"
        "conda"
        "workbox"
      ]
    ) "the workbox doesn't have the yocto, conda and workbox shells";
    pkgs.emptyFile;
}
