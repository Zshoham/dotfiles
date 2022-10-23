{ config, pkgs, ... }:

{
  dconf.enable = true;

  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri = "file:///usr/share/backgrounds/wallpaper.xml";
      picture-uri-dark = "file:///usr/share/backgrounds/wallpaper.xml";
    };
    "org/gnome/system/location".enabled = false;
    "org/gnome/shell" = {
	  favorite-apps = [ "/org/gnome/shell/favorite-apps" "com.alacritty.Alacritty.desktop" "brave-browser.desktop" ];
    };
    "org/gnome/desktop/wm/preferences".button-layout = "appmenu:minimize,maximize,close";
    "org/gnome/shell/extensions/dash-to-dock" = {
      dash-max-icon = 36;
      dock-fixed = false;
      intellihide = true;
      manualhide = false;
    };
    "org/gnome/shell/extensions/pop-shell" = {
      title-by-default = true;
      active-hint = true;
      show-title = false;
      hint-color-rgba = "rgb(213,196,161)";
      show-applications-button = false;
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
      natural-scroll = true;	
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Terminal";
      command = "$HOME/.local/bin/terminal";
      binding = "<Super>t";	
    };
  };
}
