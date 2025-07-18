#!/bin/bash
# validate-setup.sh - Script to validate the .NET dev container setup

echo "🔍 Validating .NET Dev Container Setup"
echo "====================================="
echo ""

# Check if we're in a container
if [ -f /.dockerenv ]; then
    echo "✅ Running inside Docker container"
else
    echo "⚠️ Not running inside Docker container"
fi

# Check .NET installation
echo ""
echo "📦 Checking .NET installation..."
if command -v dotnet &> /dev/null; then
    echo "✅ .NET CLI is available"
    echo "   Version: $(dotnet --version)"
    echo "   SDKs installed:"
    dotnet --list-sdks | sed 's/^/   - /'
    echo "   Runtimes installed:"
    dotnet --list-runtimes | sed 's/^/   - /'
else
    echo "❌ .NET CLI not found"
fi

# Check global tools
echo ""
echo "🛠️ Checking global tools..."
if dotnet tool list --global | grep -q "dotnet-ef"; then
    echo "✅ Entity Framework Core CLI is installed"
else
    echo "❌ Entity Framework Core CLI not found"
fi

if dotnet tool list --global | grep -q "dotnet-aspnet-codegenerator"; then
    echo "✅ ASP.NET Core code generator is installed"
else
    echo "❌ ASP.NET Core code generator not found"
fi

# Check VS Code extensions (if VS Code is available)
echo ""
echo "🎨 Checking VS Code setup..."
if command -v code &> /dev/null; then
    echo "✅ VS Code CLI is available"
    if code --list-extensions | grep -q "ms-dotnettools.csharp"; then
        echo "✅ C# extension is installed"
    else
        echo "❌ C# extension not found"
    fi
    if code --list-extensions | grep -q "ms-dotnettools.csdevkit"; then
        echo "✅ C# Dev Kit extension is installed"
    else
        echo "❌ C# Dev Kit extension not found"
    fi
else
    echo "⚠️ VS Code CLI not available (normal in container)"
fi

# Check SSH setup
echo ""
echo "🔐 Checking SSH setup..."
if [ -f ~/.ssh/id_rsa ]; then
    echo "✅ SSH private key found"
    echo "   Key type: $(ssh-keygen -l -f ~/.ssh/id_rsa | awk '{print $4}')"
    echo "   Key fingerprint: $(ssh-keygen -l -f ~/.ssh/id_rsa | awk '{print $2}')"
else
    echo "⚠️ SSH private key not found"
    echo "   Run ./dotnet/setup-ssh-dotenv.sh to set up SSH keys"
fi

if [ -f ~/.ssh/id_rsa.pub ]; then
    echo "✅ SSH public key found"
else
    echo "⚠️ SSH public key not found"
fi

# Check Git configuration
echo ""
echo "📝 Checking Git configuration..."
if command -v git &> /dev/null; then
    echo "✅ Git is available"
    echo "   Version: $(git --version)"
    if git config --global user.name &> /dev/null; then
        echo "   User: $(git config --global user.name) <$(git config --global user.email)>"
    else
        echo "   ⚠️ Git user not configured (you may want to set this)"
    fi
else
    echo "❌ Git not found"
fi

# Check development tools
echo ""
echo "🔧 Checking development tools..."
tools=("vim" "curl" "wget" "jq" "tree" "htop")
for tool in "${tools[@]}"; do
    if command -v "$tool" &> /dev/null; then
        echo "✅ $tool is available"
    else
        echo "❌ $tool not found"
    fi
done

echo ""
echo "🎉 Validation completed!"
echo ""
echo "💡 To test the setup:"
echo "   1. Create a new project: dotnet new console -n TestApp"
echo "   2. Navigate to it: cd TestApp"
echo "   3. Run it: dotnet run"
