{ config, pkgs, ... }:

{
  xdg.enable = true;
  home.sessionVariables = {
    EDITOR="nvim";
    
    GNUPGHOME = "${config.xdg.dataHome}/gnupg";
    ZDOTDIR = "${config.xdg.configHome}/zsh";
    LESSHISTFILE = "${config.xdg.stateHome}/less/history";
    TERMINFO_DIRS = "${config.xdg.dataHome}/terminfo:/usr/share/terminfo";
    IPYTHONDIR = "${config.xdg.configHome}/ipython";
    SQLITE_HISTORY = "${config.xdg.dataHome}/sqlite_history";

    GRADLE_USER_HOME = "${config.xdg.dataHome}/gradle";
    PIPX_HOME = "${config.xdg.dataHome}/pipx";
    JULIA_DEPOT_PATH = "${config.xdg.dataHome}/julia";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    GOPATH = "${config.xdg.dataHome}/golang";
    _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${config.xdg.dataHome}/java";
    PYENV_ROOT = "${config.xdg.dataHome}/pyenv";
  };

  home.sessionPath = [
    "$CARGO_HOME/bin"
    "$HOME/.local/bin"
    "$PYENV_ROOT/bin"
    "$PYENV_ROOT/shims"
  ];

  home.shellAliases = {
    ls = "exa --icons --git";
    cat = "bat";
    tree = "exa -T";
    files = "nautilus";
    dotfiles = "chezmoi";
    md = "glow";
    rm = "rm -i";
    cp = "cp -i";
    mv = "mv -i";

    ssh-start = "sudo systemctl start ssh.service";
    ssh-stop = "sudo systemctl stop ssh.service";
    ssh-status = "sudo systemctl status ssh.service";

    wget = "wget --hsts-file '${config.xdg.dataHome}/wget-hsts'";
  };
}
