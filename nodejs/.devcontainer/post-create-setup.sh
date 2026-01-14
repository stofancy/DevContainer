#!/usr/bin/env bash
set -euo pipefail

MARKER_FILE="/var/tmp/devcontainer_bootstrap.done"

# First-create/rebuild only: skip if already bootstrapped in this container FS
if [ -f "$MARKER_FILE" ]; then
    echo "⏭️ Post-create setup already completed; skipping."
    exit 0
fi

echo "🚀 Starting post-create setup..."

# Ensure .ssh exists
mkdir -p ~/.ssh
chmod 700 ~/.ssh || true

# Setup SSH keys from base64 env vars if provided and not already present
setup_ssh_keys() {
    local private_key_b64="${1:-}"
    local public_key_b64="${2:-}"

    if [ -f ~/.ssh/id_rsa ]; then
        echo "🔑 SSH private key already present; skipping creation."
        return 0
    fi

    if [ -n "$private_key_b64" ] && [ -n "$public_key_b64" ]; then
        echo "🔑 Installing SSH keys from base64 env vars..."
        echo "$private_key_b64" | base64 -d > ~/.ssh/id_rsa
        echo "$public_key_b64" | base64 -d > ~/.ssh/id_rsa.pub
        chmod 600 ~/.ssh/id_rsa
        chmod 644 ~/.ssh/id_rsa.pub
        echo "✅ SSH keys installed."
        return 0
    fi

    echo "⚠️ No SSH keys provided via env; skipping key install."
    return 0
}

setup_ssh_keys "${SSH_PRIVATE_KEY_B64:-}" "${SSH_PUBLIC_KEY_B64:-}"

# Known hosts: add once per host
echo "🔒 Ensuring known hosts..."
for host in github.com gitlab.com bitbucket.org ssh.dev.azure.com; do
    if ! grep -q "$host" ~/.ssh/known_hosts 2>/dev/null; then
        ssh-keyscan "$host" >> ~/.ssh/known_hosts 2>/dev/null || true
    fi
done

# SSH client config: write only if missing
if [ ! -f ~/.ssh/config ]; then
    echo "⚙️ Writing SSH client config..."
    cat > ~/.ssh/config << 'EOF'
Host *
        AddKeysToAgent yes
        IdentityFile ~/.ssh/id_rsa
        ServerAliveInterval 60
        ServerAliveCountMax 3
        StrictHostKeyChecking no
EOF
    chmod 600 ~/.ssh/config
fi

echo "🎉 SSH setup completed!"

echo "📦 Setting up Node.js with NVM..."

# Install NVM if missing
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if ! command -v nvm >/dev/null 2>&1; then
    echo "⬇️ Installing NVM..."
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

# Source NVM for current shell
if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
fi

# Install Node 22 LTS if not present and set default
if ! nvm ls 22 >/dev/null 2>&1; then
    echo "⬇️ Installing Node.js 22 LTS..."
    nvm install 22 --lts --latest-npm
fi

# Set default to 22 if not already
if ! nvm alias default | grep -q "-> 22"; then
    echo "🔧 Setting Node.js 22 as default..."
    nvm alias default 22
fi
nvm use default >/dev/null 2>&1 || true

echo "📋 Installed Node.js versions:"
nvm list || true

echo "🐟 Configuring Fish shell for NVM..."

# Ensure 'bass' plugin exists for Fish
if ! command -v bass >/dev/null 2>&1; then
    fish -c "fisher install edc/bass" >/dev/null 2>&1 || true
fi

FISH_CONFIG="$HOME/.config/fish/config.fish"
mkdir -p "$(dirname "$FISH_CONFIG")"
touch "$FISH_CONFIG"

# Add NVM function block once
if ! grep -q "# NVM configuration for Fish" "$FISH_CONFIG"; then
    fish -c "
    echo '' >> $FISH_CONFIG
    echo '# NVM configuration for Fish' >> $FISH_CONFIG
    echo 'function nvm' >> $FISH_CONFIG
    echo '    bass source ~/.nvm/nvm.sh --no-use ';' nvm \$argv' >> $FISH_CONFIG
    echo 'end' >> $FISH_CONFIG
    echo '' >> $FISH_CONFIG
    echo '# Auto-load nvm on Fish start' >> $FISH_CONFIG
    echo 'nvm use default --silent 2>/dev/null' >> $FISH_CONFIG
    " >/dev/null 2>&1 || true
fi

# Add greeting block once
if ! grep -q "# Welcome message" "$FISH_CONFIG"; then
    fish -c "
    echo '' >> $FISH_CONFIG
    echo '# Welcome message' >> $FISH_CONFIG
    echo 'function fish_greeting' >> $FISH_CONFIG
    echo '    echo "🚀 Node.js Dev Container Ready!"' >> $FISH_CONFIG
    echo '    echo "📦 Available package managers: npm, yarn, pnpm"' >> $FISH_CONFIG
    echo '    echo "🔧 Git tools: lazygit (lg), delta diff, GitHub CLI (gh), git aliases via plugin"' >> $FISH_CONFIG
    echo '    echo "🐟 Fish shell with Fisher plugins loaded"' >> $FISH_CONFIG
    echo 'end' >> $FISH_CONFIG
    " >/dev/null 2>&1 || true
fi

echo "✅ Fish shell configuration completed!"

echo "🗂 Ensuring shared workspaces volume exists..."
WORKSPACES_DIR="/home/node/workspaces"
mkdir -p "$WORKSPACES_DIR" || true
touch "$WORKSPACES_DIR/.keep" || true
chown -R node:node "$WORKSPACES_DIR" || true
echo "✅ Shared workspaces available at $WORKSPACES_DIR"

echo "🔧 Configuring global git identity..."
CURRENT_NAME="$(git config --global user.name || true)"
CURRENT_EMAIL="$(git config --global user.email || true)"
if [ -z "$CURRENT_NAME" ] && [ -n "${GIT_USER_NAME:-}" ]; then
    git config --global user.name "$GIT_USER_NAME"
fi
if [ -z "$CURRENT_EMAIL" ] && [ -n "${GIT_USER_EMAIL:-}" ]; then
    git config --global user.email "$GIT_USER_EMAIL"
fi

# Core Git defaults (safe to reapply)
git config --global init.defaultBranch main || true
git config --global pull.rebase false || true
git config --global core.pager "delta" || true
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit" || true

echo "✅ Git configured."

# Mark completion for this container instance
touch "$MARKER_FILE"

echo "⚡ Modern development environment ready!"