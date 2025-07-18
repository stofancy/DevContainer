# Dev Container Setup

This dev container provides a fully configured .NET development environment with SSH keys support.

## Quick Start Guide

### 1. Prerequisites
- VS Code with the Dev Containers extension installed
- Docker Desktop running on your machine

### 2. Build and Open Dev Container

**Option A: Command Palette (Recommended)**
1. Open VS Code in this workspace folder
2. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
3. Type "Dev Containers: Rebuild and Reopen in Container"
4. Select it and wait for the container to build

**Option B: Notification Popup**
1. Open VS Code in this workspace folder
2. VS Code should show a popup asking "Reopen in Container"
3. Click "Reopen in Container"

**Option C: Status Bar**
1. Open VS Code in this workspace folder
2. Click the green status bar item in the bottom-left corner
3. Select "Reopen in Container"

### 3. First Build
The first build will take a few minutes as it downloads and sets up:
- .NET 8.0 SDK (with .NET 6.0 and 7.0 runtimes)
- Development tools and VS Code extensions
- Global .NET tools (Entity Framework Core CLI, ASP.NET Core code generator, etc.)

## SSH Keys Setup

To use SSH keys for Git operations and other SSH-based tasks in the dev container:

### Simple Template-Based Setup

1. **Copy and edit the template file** with your SSH keys:
   ```bash
   # Copy the example template
   cp ./dotnet/.ssh-keys-template.example ./dotnet/.ssh-keys-template
   
   # Edit this file with your actual SSH keys
   # Your keys are typically in ~/.ssh/id_rsa and ~/.ssh/id_rsa.pub
   ./dotnet/.ssh-keys-template
   ```

2. **Run the setup script**:
   ```bash
   ./dotnet/setup-ssh-dotenv.sh
   ```

3. **Rebuild your dev container**:
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
   - Type "Dev Containers: Rebuild Container"
   - Select it and wait for completion

### Template File Format

The `.ssh-keys-template` file should contain:

```bash
# Private Key (including BEGIN/END lines):
PRIVATE_KEY="-----BEGIN OPENSSH PRIVATE KEY-----
your_private_key_content_here
-----END OPENSSH PRIVATE KEY-----"

# Public Key (single line):
PUBLIC_KEY="ssh-rsa your_public_key_content_here your_email@example.com"
```

**Note:** Copy from `.ssh-keys-template.example` to get started, then replace the placeholder content with your actual SSH keys.

### Security Notes

- Copy `.ssh-keys-template.example` to `.ssh-keys-template` and edit with your real keys
- The template file `.ssh-keys-template` is automatically deleted after processing for security
- SSH keys are base64-encoded before being stored in the `.env` file
- The `.env` file is already in `.gitignore` to prevent accidental commits
- The `.ssh-keys-template` file is also in `.gitignore` to prevent committing real SSH keys

## What's Included

### .NET Development Stack
- .NET 8.0 SDK (latest)
- .NET 6.0 and 7.0 runtimes for compatibility
- Global tools:
  - Entity Framework Core CLI (`dotnet-ef`)
  - ASP.NET Core code generator (`dotnet-aspnet-codegenerator`)
  - NuGet CLI
- Additional project templates (SPA, Web API, etc.)

### Development Tools
- Git configuration with useful aliases
- SSH client with automatic key setup
- Vim configured for C# development (4-space indentation)
- Zsh with oh-my-zsh and useful plugins

### VS Code Extensions
- C# Dev Kit
- C# language support
- .NET Test Explorer
- PowerShell
- JSON support

## Quick Start Commands

After the container is running, try these commands:

```bash
# Check .NET installation
dotnet --version
dotnet --list-sdks

# Create a new console application
dotnet new console -n MyApp
cd MyApp
dotnet run

# Create a new Web API
dotnet new webapi -n MyWebAPI
cd MyWebAPI
dotnet run

# Create a new MVC application
dotnet new mvc -n MyMvcApp
cd MyMvcApp
dotnet run

# Create a new Blazor Server application
dotnet new blazorserver -n MyBlazorApp
cd MyBlazorApp
dotnet run

# List available project templates
dotnet new list --type project

# List installed global tools
dotnet tool list --global

# Add Entity Framework to a project
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools

# Create a migration (if using EF Core)
dotnet ef migrations add InitialCreate
dotnet ef database update
```

## Validation

To verify that everything is set up correctly, run the validation script:

```bash
./dotnet/validate-setup.sh
```

This script will check:
- .NET installation and versions
- Global tools installation
- SSH keys setup
- Git configuration
- Development tools availability

## Security Notes

- The `.env` file contains sensitive SSH keys and should never be committed to version control
- Make sure `.env` is in your `.gitignore`
- SSH keys are automatically set up in the container at startup

## Troubleshooting

### Container Won't Build
1. Make sure Docker Desktop is running
2. Check if you have sufficient disk space
3. Try rebuilding without cache: `Ctrl+Shift+P` → "Dev Containers: Rebuild Container (No Cache)"

### SSH Keys Not Working
1. Ensure SSH keys exist on your host machine (`~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`)
2. Run the setup script: `./dotnet/setup-ssh-dotenv.sh`
3. Rebuild the container after creating the `.env` file

### Extensions Not Loading
1. Make sure you're connected to the container (check the green status bar)
2. Extensions are automatically installed during container creation
3. If missing, reload the window: `Ctrl+Shift+P` → "Developer: Reload Window"

### .NET Issues
1. If `dotnet` command is not found, try reloading the terminal
2. For OmniSharp issues, restart the C# extension: `Ctrl+Shift+P` → "C#: Restart OmniSharp"
3. Check .NET installation: `dotnet --info`

## Manual Commands

If you prefer using the command line:

```bash
# Build the container
docker build -t dotnet-devcontainer dotnet/

# Run with volume mounts (VS Code handles this automatically)
docker run -it --rm -v "$(pwd)":/workspace dotnet-devcontainer
```
