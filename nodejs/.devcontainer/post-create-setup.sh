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

echo "✅ Git identity configured (defaults are baked into image)."

# Mark completion for this container instance
touch "$MARKER_FILE"

echo "⚡ Modern development environment ready!"