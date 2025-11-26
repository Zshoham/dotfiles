alias cat bat
alias ls lsd
alias tree 'lsd --tree'
alias files nautilus
alias dotfiles chezmoi
alias md glow
alias rm "rm -i"
alias cp "cp -i"
alias mv "mv -i"
alias mamba micromamba

function tomb
    zsh -c "DISPLAY= tomb $argv"
end

alias wget "wget --hsts-file '$XDG_DATA_HOME'/wget-hsts"

# ssh
alias ssh-start 'sudo systemctl start ssh.service'
alias ssh-stop 'sudo systemctl stop ssh.service'
alias ssh-status 'sudo systemctl status ssh.service'

# nix
alias nix-update 'nix-channel --update; nix-env -u --dry-run'
alias nix-upgrade 'nix-env -u'
alias nix-generations 'nix-env --list-generations'
