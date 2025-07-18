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
    echo "To add SSH keys, run the setup script: ./.devcontainer/setup-ssh-dotenv.sh"
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

echo ""
echo "🚀 Node.js setup completed!"
echo "✅ Post container setup completed!"