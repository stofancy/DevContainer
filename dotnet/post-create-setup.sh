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
    echo "To add SSH keys, run the setup script: ./dotnet/setup-ssh-dotenv.sh"
    echo "Or copy the example template: cp ./dotnet/.ssh-keys-template.example ./dotnet/.ssh-keys-template"
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

# Setup .NET development environment
echo ""
echo "📦 Setting up .NET development environment..."

# Verify .NET installation
echo "🔍 Verifying .NET installation..."
dotnet --version
dotnet --list-sdks
dotnet --list-runtimes

# Install useful .NET global tools
echo ""
echo "🛠️ Installing useful .NET global tools..."

# Install Entity Framework Core CLI tools
echo "⬇️ Installing Entity Framework Core CLI tools..."
dotnet tool install --global dotnet-ef

# Install ASP.NET Core code generator
echo "⬇️ Installing ASP.NET Core code generator..."
dotnet tool install --global dotnet-aspnet-codegenerator

# Install .NET project templates
echo "⬇️ Installing additional project templates..."
dotnet new install Microsoft.AspNetCore.SPA.ProjectTemplates
dotnet new install Microsoft.DotNet.Web.ProjectTemplates

# Install NuGet CLI (if needed)
echo "⬇️ Installing NuGet CLI..."
dotnet tool install --global nuget

# Setup global.json for consistent SDK version
echo ""
echo "📋 Available .NET templates:"
dotnet new list --type project

echo ""
echo "🔧 .NET global tools installed:"
dotnet tool list --global

echo ""
echo "🚀 .NET setup completed!"
echo "✅ Post container setup completed!"