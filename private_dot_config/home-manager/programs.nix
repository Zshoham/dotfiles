{ config, pkgs, ... }:

{
  programs = {
    home-manager.enable = true;
    bash.enable = true;

    ssh = {
      enable = true;
      extraOptionOverrides = {
        identityFile = "~/.ssh/shoham_sshid";
      };
    };

    git = {
      enable = true;
      userEmail = "ShohamZarfti@gmail.com";
      userName = "Zshoham";
      delta.enable = true;
    };

    bat = {
      enable = true;
      config = {
        theme = "catppuccin";
        italic-text = "always";
      };
      themes = {
        catppuccin = builtins.readFile (pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "bat";
          rev = "f0dedf515c02799b76a2804db9815a479f6c0075";
          sha256 = "sha256-cdFqNn9LsvRHN/EY8/BQNKMANOWxv9Qg7uAcF8TsN3w=";
        } + "/Catppuccin-mocha.tmTheme");
      };
    };

    starship = {
      enable = true;
      settings = {
      conda.ignore_base = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[✗](bold red)";
        };
      };
    };

    zellij = {
      enable = true;
      settings = {
      	simplified_ui = true;
		pane_frames = false;
        theme = "catppuccin";
		themes.catppuccin = {
		  fg = "#cdd6f4";
		  bg = "#585b70";
		  red = "#f38ba8";
		  green = "#a6e3a1";
		  blue = "#89b4fa";
          yellow = "#f9e2af";
          magenta = "#f5c2e7"; 
          orange = "#fab387"; 
          cyan = "#89dceb"; 
          black = "#181825"; 
          white = "#cdd6f4";
		};
      };
    };
  };
}
