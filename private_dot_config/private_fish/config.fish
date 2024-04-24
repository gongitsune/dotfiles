if status is-interactive
    # Commands to run in interactive sessions can go here
end

# starship settings
starship init fish | source

# ghcup and cabal
fish_add_path $HOME/.cabal/bin
fish_add_path $HOME/.ghcup/bin
fish_add_path $HOME/.local/bin

# mise setting
/usr/bin/mise activate fish | source

# pnpm
set -gx PNPM_HOME "/home/keigo/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end


set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME ; set -gx PATH $HOME/.cabal/bin /home/keigo/.ghcup/bin $PATH # ghcup-env