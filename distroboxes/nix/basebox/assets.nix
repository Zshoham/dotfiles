# Files the arch image downloads into the home directory at build time.
# Here they are packaged into share/ and linked into the home directory by
# basebox-init.
{
  runCommand,
  fetchurl,
  fetchgit,
  writeTextFile,
}:

{
  zellij-plugins = runCommand "zellij-plugins" { } ''
    mkdir -p $out/share/zellij/plugins
    ln -s ${
      fetchurl {
        url = "https://github.com/dj95/zjstatus/releases/download/v0.25.0/zjstatus.wasm";
        hash = "sha256-KCzqshnlbhkIyfrDOQckH+bD4e99hfqrPl9DjO+HuP4=";
      }
    } $out/share/zellij/plugins/zjstatus.wasm
    ln -s ${
      fetchurl {
        url = "https://github.com/rvcas/room/releases/download/v1.2.1/room.wasm";
        hash = "sha256-kLSDpAt2JGj7dYYhYFh6BfvtzVwTrcs+0jHwG/nActE=";
      }
    } $out/share/zellij/plugins/room.wasm
    ln -s ${
      fetchurl {
        url = "https://github.com/karimould/zellij-forgot/releases/download/0.4.2/zellij_forgot.wasm";
        hash = "sha256-MRlBRVGdvcEoaFtFb5cDdDePoZ/J2nQvvkoyG6zkSds=";
      }
    } $out/share/zellij/plugins/zellij_forgot.wasm
  '';

  gef = runCommand "gef-script" { } ''
    install -Dm644 ${
      fetchurl {
        url = "https://raw.githubusercontent.com/hugsy/gef/2026.01/gef.py";
        hash = "sha256-BM3+lh8ekVGTPTLPa1SNnmp2oa74snwCDFdbjUJk7SA=";
      }
    } $out/share/gef/gef.py
  '';

  # fish picks up functions and completions from the vendor directories.
  replay-fish =
    let
      src = fetchgit {
        url = "https://github.com/jorgebucaran/replay.fish";
        rev = "1.2.1";
        hash = "sha256-bM6+oAd/HXaVgpJMut8bwqO54Le33hwO9qet9paK1kY=";
      };
    in
    runCommand "replay-fish" { } ''
      install -Dm644 ${src}/functions/replay.fish $out/share/fish/vendor_functions.d/replay.fish
      install -Dm644 ${src}/completions/replay.fish $out/share/fish/vendor_completions.d/replay.fish
    '';

  basebox-init = writeTextFile {
    name = "basebox-init";
    destination = "/bin/basebox-init";
    executable = true;
    text = builtins.readFile ./init.fish;
  };
}
