if status is-interactive
    # Commands to run in interactive sessions can go here
end

# pure settings
set pure_show_system_time true
set pure_color_system_time 858585
set pure_color_git_branch 858585

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
