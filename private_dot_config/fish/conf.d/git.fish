function gcw -d "Git Change Worktree - move to another worktree in this project"
    set selected_worktree (git worktree list | fzf --reverse --height 40% | cut -d ' ' -f1)
    cd $selected_worktree
end
