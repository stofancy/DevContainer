#!/bin/bash
# setup-ssh-dotenv.sh - Create .env file with SSH keys for Node.js dev container
# 
# Usage:
#   ./.devcontainer/setup-ssh-dotenv.sh [--help]
#
# This script reads SSH keys from a template file, base64-encodes them,
# and creates a .env file for the dev container.

set -e

# Paths relative to the repository root
ENV_FILE_PATH="./.devcontainer/.env"
TEMPLATE_FILE="./.devcontainer/.ssh-keys-template"
EXAMPLE_FILE="./.devcontainer/.ssh-keys-template.example"

echo "🔑 SSH Keys Setup for Node.js Dev Container"
echo "============================================"
echo ""

# Function to show help
show_help() {
    echo "Usage: $0 [--help]"
    echo ""
    echo "Sets up SSH keys in a .env file for use in the Node.js dev container."
    echo ""
    echo "Quick Start:"
    echo "  1. cp ./.devcontainer/.ssh-keys-template.example ./.devcontainer/.ssh-keys-template"
    echo "  2. Edit ./.devcontainer/.ssh-keys-template with your SSH keys"
    echo "  3. Run: ./.devcontainer/setup-ssh-dotenv.sh"
    echo "  4. Rebuild container: Ctrl+Shift+P → 'Dev Containers: Rebuild Container'"
    echo ""
    echo "Options:"
    echo "  --help              Show this help message"
    echo ""
    echo "Details:"
    echo "  • Reads SSH keys from ./.devcontainer/.ssh-keys-template"
    echo "  • Base64-encodes them for safe storage in .env"
    echo "  • Creates ./.devcontainer/.env (automatically git-ignored)"
    echo "  • Deletes .ssh-keys-template for security"
}

# Function to setup from template file
setup_from_template() {
    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        echo "❌ Template file not found: $TEMPLATE_FILE"
        echo ""
        echo "📝 Create it with:"
        echo "   cp $EXAMPLE_FILE $TEMPLATE_FILE"
        echo ""
        echo "📖 Then edit $TEMPLATE_FILE:"
        echo "   • Replace YOUR_PRIVATE_KEY_CONTENT_GOES_HERE with your private key (from ~/.ssh/id_rsa)"
        echo "   • Replace YOUR_PUBLIC_KEY_CONTENT_GOES_HERE with your public key (from ~/.ssh/id_rsa.pub)"
        echo "   • Keep the BEGIN/END lines and format intact"
        echo ""
        echo "🚀 Then run this script again:"
        echo "   $0"
        return 1
    fi
    
    echo "📁 Reading keys from: $TEMPLATE_FILE"
    
    # Source the template file (reads PRIVATE_KEY and PUBLIC_KEY variables)
    # shellcheck source=/dev/null
    source "$TEMPLATE_FILE" 2>/dev/null || {
        echo "❌ Failed to read template file"
        return 1
    }
    
    # Validate keys aren't still placeholder text
    if [[ "$PRIVATE_KEY" == *"YOUR_PRIVATE_KEY_CONTENT_GOES_HERE"* ]]; then
        echo "❌ Error: Private key still contains placeholder text"
        echo "💡 Edit $TEMPLATE_FILE and replace the placeholder with your actual key"
        return 1
    fi
    
    if [[ "$PUBLIC_KEY" == *"YOUR_PUBLIC_KEY_CONTENT_GOES_HERE"* ]]; then
        echo "❌ Error: Public key still contains placeholder text"
        echo "💡 Edit $TEMPLATE_FILE and replace the placeholder with your actual key"
        return 1
    fi
    
    # Validate both keys are present
    if [[ -z "$PRIVATE_KEY" || -z "$PUBLIC_KEY" ]]; then
        echo "❌ Error: PRIVATE_KEY or PUBLIC_KEY is empty in $TEMPLATE_FILE"
        return 1
    fi
    
    # Validate key format
    if [[ ! "$PRIVATE_KEY" =~ "BEGIN".*"END" ]]; then
        echo "❌ Error: Private key doesn't look valid (missing BEGIN/END headers)"
        return 1
    fi
    
    if [[ ! "$PUBLIC_KEY" =~ ^ssh- ]]; then
        echo "❌ Error: Public key doesn't look valid (should start with 'ssh-')"
        return 1
    fi
    
    echo "✅ Keys look valid!"
    
    PRIVATE_KEY_CONTENT="$PRIVATE_KEY"
    PUBLIC_KEY_CONTENT="$PUBLIC_KEY"
    
    # Delete template file for security
    rm -f "$TEMPLATE_FILE"
    echo "🗑️  Removed template file for security"
    
    return 0
}

# Parse command line arguments
case "$1" in
    --help)
        show_help
        exit 0
        ;;
    "")
        # Run the template setup
        if ! setup_from_template; then
            exit 1
        fi
        ;;
    *)
        echo "❌ Unknown option: $1"
        echo ""
        show_help
        exit 1
        ;;
esac

# Encode to base64 and create .env file
echo "🔄 Base64-encoding SSH keys..."
PRIVATE_KEY_B64=$(echo "$PRIVATE_KEY_CONTENT" | base64 -w 0)
PUBLIC_KEY_B64=$(echo "$PUBLIC_KEY_CONTENT" | base64 -w 0)

echo "📝 Creating .env file..."
{
    echo "# SSH Keys for Node.js Dev Container (Auto-generated)"
    echo "# DO NOT EDIT - use setup-ssh-dotenv.sh to update"
    echo "SSH_PRIVATE_KEY_B64=$PRIVATE_KEY_B64"
    echo "SSH_PUBLIC_KEY_B64=$PUBLIC_KEY_B64"
} > "$ENV_FILE_PATH"

chmod 600 "$ENV_FILE_PATH"

echo ""
echo "✅ SSH .env file created successfully!"
echo "📁 Location: $ENV_FILE_PATH"
echo ""
echo "🚀 Next Step: Rebuild the dev container"
echo "   Ctrl+Shift+P → 'Dev Containers: Rebuild Container'"
echo ""
echo "Your SSH keys will be available inside the container automatically."
echo "Verify with: ssh-add -l"
