source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
   # smth smth
end

if status is-interactive
    if not set -q TMUX
      exec tmux
    end
end

export EDITOR=nvim

mise activate fish | source
zoxide init fish | source

alias cd="z"
alias cdi="zi"
