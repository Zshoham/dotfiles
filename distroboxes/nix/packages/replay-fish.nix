# replay.fish, in the fish vendor directories.
{ fetchgit, runCommand }:

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
''
