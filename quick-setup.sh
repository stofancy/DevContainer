#!/bin/bash
# quick-setup.sh - Quick setup script for SSH keys templates

echo "🚀 Quick Setup for DevContainer SSH Keys"
echo "========================================"
echo ""

# Function to setup for a specific environment
setup_environment() {
    local env="$1"
    echo "Setting up $env environment..."
    
    if [[ ! -f "./$env/.ssh-keys-template.example" ]]; then
        echo "❌ Example template not found: ./$env/.ssh-keys-template.example"
        return 1
    fi
    
    if [[ -f "./$env/.ssh-keys-template" ]]; then
        echo "⚠️ Template file already exists: ./$env/.ssh-keys-template"
        read -p "Do you want to overwrite it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Skipping $env..."
            return 0
        fi
    fi
    
    cp "./$env/.ssh-keys-template.example" "./$env/.ssh-keys-template"
    echo "✅ Template created: ./$env/.ssh-keys-template"
    echo "📝 Next steps for $env:"
    echo "   1. Edit ./$env/.ssh-keys-template with your SSH keys"
    echo "   2. Run ./$env/setup-ssh-dotenv.sh"
    echo ""
}

# Check which environments are available and set them up
if [[ -d "./nodejs" ]]; then
    setup_environment "nodejs"
fi

if [[ -d "./dotnet" ]]; then
    setup_environment "dotnet"
fi

echo "🎉 Quick setup completed!"
echo ""
echo "📖 For detailed instructions, see the README.md in each environment folder."
echo "💡 Remember to edit the template files with your actual SSH keys before running the setup scripts."
