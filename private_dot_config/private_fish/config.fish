if status is-interactive
    # Commands to run in interactive sessions can go here
    fzf_configure_bindings
end

# starship
starship init fish | source

# mise
mise activate fish | source
