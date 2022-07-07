
function bwr
    set COPY "xclip -sel clip"
    set CLEAR "xclip -sel clip < /dev/null"
    if test "unauthenticated" = (bw status | jq .status)
        bw login
    end
    set logins (bw list items)
    set name (echo $logins | jq '.[].name' | fzf)
    set selected (echo $logins | jq -r ".[] | select(.name == $name)")
    
    echo "Name: $name"
    echo "> Copying username to clipboard"
    printf '%s' (echo $selected | jq -r '.login.username') | eval $COPY
    echo "Press any key to copy password"
    read
    echo "> Copying password to clipboard"
    printf '%s' (echo $selected | jq -r '.login.password') | eval $COPY   
    echo "Press any key to clear clipboard"
    read
    eval $CLEAR
end
