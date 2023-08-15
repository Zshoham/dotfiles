
function z -d "Launch zellij"
  if test $argv[1]
    zellij -s $argv[1]
    return
  end

  set ZJ_SESSIONS (zellij list-sessions)

  if test (count $ZJ_SESSIONS) -gt 1
    zellij attach (printf "%s\n" $ZJ_SESSIONS | fzf --reverse --height 40%)
  else
    zellij attach -c
  end
end
