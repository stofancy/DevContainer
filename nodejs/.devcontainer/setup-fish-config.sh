#!/bin/bash
# Setup Fish shell configuration

# Create directory if it doesn't exist
mkdir -p ~/.config/fish

# Write Fish config file
cat > ~/.config/fish/config.fish << 'EOF'
# Fish configuration

# Set environment variables
set -gx EDITOR vim
set -gx VISUAL vim

# Git aliases provided by jhillyerd/plugin-git plugin
# Available aliases include: gst, gd, ga, gc, gp, gl, gco, glog, etc.
# Use "abbr --list | grep git" to see all available git abbreviations

# Modern tool aliases
alias lg "lazygit"

# Package manager shortcuts
alias pn "pnpm"
alias yr "yarn"

# SSH Agent configuration
if test -z "$SSH_AUTH_SOCK"
    eval (ssh-agent -c)
    ssh-add ~/.ssh/id_rsa 2>/dev/null
end

# NVM configuration for Fish (only if installed)
if test -f ~/.nvm/nvm.sh
    function nvm
        bass source ~/.nvm/nvm.sh --no-use ";" nvm $argv
    end

    # Auto-load nvm on Fish start
    nvm use default --silent 2>/dev/null
end

# Welcome message
function fish_greeting
    echo "🚀 Node.js Dev Container Ready!"
    echo "📦 Available package managers: npm, yarn, pnpm"
    echo "🔧 Git tools: lazygit (lg), delta diff, GitHub CLI (gh), git aliases via plugin"
    echo "🐟 Fish shell with Fisher plugins loaded"
end
EOF
