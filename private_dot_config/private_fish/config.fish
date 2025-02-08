if status is-interactive
    # Commands to run in interactive sessions can go here
    fzf_configure_bindings
end

# starship
starship init fish | source

# mise
mise activate fish | source

# pnpm
set -gx PNPM_HOME "/home/keigo/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
