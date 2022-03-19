alias cat bat
alias ls 'exa --icons --git'
alias tree 'exa -T'
alias files nautilus
alias dotfiles chezmoi

# ssh
alias ssh-start 'sudo systemctl start ssh.service'
alias ssh-stop 'sudo systemctl stop ssh.service'
alias ssh-status 'sudo systemctl status ssh.service'

# nix
alias nix-update 'nix-channel --update; nix-env -u --dry-run'
alias nix-upgrade 'nix-env -u'
alias nix-generations 'nix-env --list-generations'
