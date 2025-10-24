#!/bin/bash
set -e

echo "🚀 Starting SSH setup..."

# Create .ssh directory
mkdir -p ~/.ssh

# Function to setup SSH keys
setup_ssh_keys() {
    local private_key_b64="$1"
    local public_key_b64="$2"
    
    # Setup SSH keys from base64 encoded environment variables
    if [ -n "$private_key_b64" ] && [ -n "$public_key_b64" ]; then
        echo "🔑 Setting up SSH keys from base64 encoded environment variables..."
        echo "$private_key_b64" | base64 -d > ~/.ssh/id_rsa
        echo "$public_key_b64" | base64 -d > ~/.ssh/id_rsa.pub
        chmod 600 ~/.ssh/id_rsa
        chmod 644 ~/.ssh/id_rsa.pub
        echo "✅ SSH keys set up successfully from base64 encoded environment variables."
        return 0
    fi
    
    echo "⚠️ Warning: No SSH keys found in environment variables."
    echo "SSH key authentication will not be available."
    echo "To add SSH keys, run the setup script: ./nodejs/setup-ssh-dotenv.sh"
    echo "Or copy the example template: cp ./nodejs/.ssh-keys-template.example ./nodejs/.ssh-keys-template"
    return 1
}

# Setup SSH keys
setup_ssh_keys "$SSH_PRIVATE_KEY_B64" "$SSH_PUBLIC_KEY_B64"

# Setup known hosts regardless of whether keys were found
echo "🔒 Setting up known hosts..."
ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null || true
ssh-keyscan gitlab.com >> ~/.ssh/known_hosts 2>/dev/null || true
ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts 2>/dev/null || true
ssh-keyscan ssh.dev.azure.com >> ~/.ssh/known_hosts 2>/dev/null || true

# Configure SSH
echo "⚙️ Configuring SSH client..."
cat > ~/.ssh/config << 'EOF'
Host *
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_rsa
    ServerAliveInterval 60
    ServerAliveCountMax 3
    StrictHostKeyChecking no
EOF
chmod 600 ~/.ssh/config

echo "🎉 SSH setup completed!"

# Setup Node.js versions with nvm
echo ""
echo "📦 Setting up Node.js LTS versions..."

# Source nvm to make it available in this script
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install the last 3 major LTS versions
echo "⬇️ Installing Node.js 22 LTS (Jod)..."
nvm install 22 --lts --latest-npm
echo "✅ Node.js 22 LTS installed"

# Set Node.js 22 as the default version
echo ""
echo "🔧 Setting Node.js 22 LTS as default..."
nvm alias default 22
nvm use default

echo ""
echo "📋 Installed Node.js versions:"
nvm list

# Setup Fish shell configuration for nvm
echo ""
echo "� Setting up Fish shell configuration..."

# Add NVM configuration to Fish config
fish -c "
echo '' >> ~/.config/fish/config.fish
echo '# NVM configuration for Fish' >> ~/.config/fish/config.fish
echo 'function nvm' >> ~/.config/fish/config.fish
echo '    bass source ~/.nvm/nvm.sh --no-use ';' nvm \$argv' >> ~/.config/fish/config.fish
echo 'end' >> ~/.config/fish/config.fish
echo '' >> ~/.config/fish/config.fish
echo '# Auto-load nvm on Fish start' >> ~/.config/fish/config.fish
echo 'nvm use default --silent 2>/dev/null' >> ~/.config/fish/config.fish
" 2>/dev/null || true

echo "✅ NVM configuration for Fish completed!"

# Setup welcome message for Fish
fish -c "
echo '' >> ~/.config/fish/config.fish
echo '# Welcome message' >> ~/.config/fish/config.fish
echo 'function fish_greeting' >> ~/.config/fish/config.fish
echo '    echo \"�🚀 Node.js Dev Container Ready!\"' >> ~/.config/fish/config.fish
echo '    echo \"📦 Available package managers: npm, yarn, pnpm\"' >> ~/.config/fish/config.fish
echo '    echo \"🔧 Git tools: lazygit (lg), delta diff, GitHub CLI (gh), git aliases via plugin\"' >> ~/.config/fish/config.fish
echo '    echo \"🐟 Fish shell with Fisher plugins loaded\"' >> ~/.config/fish/config.fish
echo 'end' >> ~/.config/fish/config.fish
"

echo "✅ Fish shell configuration completed!"

echo ""
echo "🚀 Node.js setup completed!"
echo "✅ Post container setup completed!"

# Display installed tools summary
echo ""
echo "📋 Summary of installed tools:"
echo "  🐟 Fish shell with Fisher plugin manager"
echo "  📦 Package managers: npm, yarn, pnpm"  
echo "  🔧 Git tools: delta, lazygit, GitHub CLI, git-extras"
echo "  🎨 Fish plugins: autopair, done, fzf, z navigation, bobthefish theme"
echo ""
echo "🗂 Ensuring shared workspaces volume exists..."
WORKSPACES_DIR="/home/node/workspaces"
mkdir -p "$WORKSPACES_DIR" || true
touch "$WORKSPACES_DIR/.keep" || true
chown -R node:node "$WORKSPACES_DIR" || true
echo "✅ Shared workspaces available at $WORKSPACES_DIR"

echo "🔧 Configuring global git identity..."
GIT_NAME="${GIT_USER_NAME:-${NPM_IDENT:-DevContainer User}}"
GIT_EMAIL="${GIT_USER_EMAIL:-devcontainer@example.invalid}"
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.pager "delta"
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
echo "✅ Git identity set to: $GIT_NAME <$GIT_EMAIL>"
echo "  ⚡ Modern development environment ready!"