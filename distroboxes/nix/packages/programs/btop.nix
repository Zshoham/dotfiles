# btop with its config and theme from config/btop.
{ pkgs, wrappers }:

(wrappers.wrapperModules.btop.apply {
  inherit pkgs;
  "btop.conf".path = "${../../config/btop/btop.conf}";
  flags."--themes-dir" = "${../../config/btop/themes}";
}).wrapper
