bindkey -e

# correctly bind delete, home, and end keys
bindkey "^[[3~" delete-char
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line
