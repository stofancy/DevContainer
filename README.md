# DevContainer Templates

This repository contains pre-configured development container templates for different technology stacks.

## Available Environments

### 🟢 Node.js Development Container
**Location:** `nodejs/`

- **Base:** Node.js 22 LTS with npm and essential tools
- **Features:** ESLint, Prettier, NVM support
- **Extensions:** JavaScript/TypeScript development extensions
- **Tools:** Git, SSH, Zsh with Oh My Zsh

[📖 See nodejs/README.md for detailed setup instructions](nodejs/README.md)

### 🔵 .NET Development Container  
**Location:** `dotnet/`

- **Base:** .NET 8.0 SDK with 6.0 and 7.0 runtimes
- **Features:** Entity Framework CLI, ASP.NET Core tools, NuGet
- **Extensions:** C# Dev Kit, OmniSharp, PowerShell
- **Tools:** Git, SSH, Zsh with Oh My Zsh

[📖 See dotnet/README.md for detailed setup instructions](dotnet/README.md)

### 📁 Shared Workspaces Volume
All devcontainers share a persistent folder mounted at `~/workspaces` using the named Docker volume `devcontainer-shared-workspaces`. Files placed there are preserved across rebuilds and are accessible from every stack (Node.js, .NET, Fullstack Aspire, etc.). Use it for:

- Scratch projects or experiments
- Cross-stack assets (scripts, notes, temp repos)
- Cloning repos you want accessible everywhere

The volume is mounted per environment at:

- Node.js: `/home/node/workspaces`
- .NET: `/home/vscode/workspaces`
- Fullstack: `/home/vscode/workspaces`

Initialization happens automatically via each environment's post-create script. A `.keep` file and minimal `.gitignore` are added if missing.

To inspect the volume from the host:

```bash
docker volume inspect devcontainer-shared-workspaces
```

To remove (will delete all shared data):

```bash
docker volume rm devcontainer-shared-workspaces
```

To back up:

```bash
docker run --rm -v devcontainer-shared-workspaces:/data -v "$PWD":/backup alpine tar -czf /backup/workspaces-backup.tgz -C /data .
```

### Git Identity Configuration

Set your global git identity via environment variables placed in the `.devcontainer/.env` file for each stack (or a shared template):

```bash
GIT_USER_NAME="Your Name"
GIT_USER_EMAIL="your.email@example.com"
```

The post-create scripts will apply these to `git config --global user.name` and `user.email`. If unset, they fall back to `NPM_IDENT` or a placeholder.


## Quick Start

### 1. Prerequisites

- VS Code with the Dev Containers extension
- Docker Desktop running

### 2. Choose Your Environment

Navigate to the appropriate folder (`nodejs/` or `dotnet/`) and follow the README instructions.

### 3. SSH Keys Setup (Optional but Recommended)

For Git operations and SSH access, set up SSH keys:

```bash
# Quick setup for both environments (copies example templates)
./quick-setup.sh

# Or manually for a specific environment:
cp ./nodejs/.ssh-keys-template.example ./nodejs/.ssh-keys-template
# Edit ./nodejs/.ssh-keys-template with your SSH keys
./nodejs/setup-ssh-dotenv.sh


### 4. Open in Container

1. Open VS Code in the desired environment folder
2. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
3. Type "Dev Containers: Rebuild and Reopen in Container"
4. Wait for the container to build and configure

## Project Structure

```
DevContainer/
├── nodejs/                     # Node.js development environment
│   ├── .ssh-keys-template.example  # Safe SSH template (committed)
│   ├── devcontainer.json      # VS Code dev container config
│   ├── Dockerfile             # Container definition
│   ├── setup-ssh-dotenv.sh    # SSH setup script
│   ├── post-create-setup.sh   # Post-creation setup
│   ├── validate-setup.sh      # Environment validation
│   └── README.md              # Node.js specific docs
├── dotnet/                     # .NET development environment
│   ├── .ssh-keys-template.example  # Safe SSH template (committed)
│   ├── devcontainer.json      # VS Code dev container config
│   ├── Dockerfile             # Container definition
│   ├── setup-ssh-dotenv.sh    # SSH setup script
│   ├── post-create-setup.sh   # Post-creation setup
│   ├── validate-setup.sh      # Environment validation
│   └── README.md              # .NET specific docs
├── quick-setup.sh             # Quick SSH template setup
├── .gitignore                 # Git ignore rules
└── README.md                  # This file

## Security Features

### SSH Key Management

- **Safe Templates:** `.ssh-keys-template.example` files contain only placeholder text and are safe to commit
- **Secure Usage:** Real SSH keys go in `.ssh-keys-template` files that are automatically ignored by git
- **Automatic Cleanup:** Template files with real keys are deleted after processing for security

### Environment Isolation

- Each environment uses an `.env` file in its root folder (e.g. `nodejs/.env`) with base64-encoded SSH keys and optional git identity variables
- All sensitive files (`.env`, `.ssh-keys-template`) are in `.gitignore`
- Containers run with non-root users for security

## Adding New Environments

To add a new technology stack:

1. Create a new folder (e.g., `python/`, `go/`, etc.)
2. Copy and adapt the structure from an existing environment
3. Update the base image and dependencies in `Dockerfile`
4. Modify `devcontainer.json` for appropriate extensions
5. Adapt `post-create-setup.sh` for the new stack
6. Create stack-specific documentation in the folder's `README.md`
7. Update this root README.md

## Common Commands

```bash
# List available environments
ls -la

# Quick setup SSH templates for all environments
./quick-setup.sh

# Validate a specific environment (run inside container)
./nodejs/validate-setup.sh
./dotnet/validate-setup.sh

# Check what's being ignored by git
git status --ignored
```

## Troubleshooting

### Container Won't Build

1. Ensure Docker Desktop is running
2. Check available disk space
3. Try rebuilding without cache: "Dev Containers: Rebuild Container (No Cache)"

### SSH Keys Issues

1. Verify your SSH keys exist: `ls -la ~/.ssh/`
2. Copy the template: `cp ./<env>/.ssh-keys-template.example ./<env>/.ssh-keys-template`
3. Edit the template with your actual keys
4. Run the setup script: `./<env>/setup-ssh-dotenv.sh`

### Extensions Not Loading

1. Check you're connected to the container (green status bar in VS Code)
2. Reload window: `Ctrl+Shift+P` → "Developer: Reload Window"

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with actual dev containers
5. Submit a pull request

## License

This project is open source and available under the [MIT License](LICENSE).

---

**🚀 Happy coding in your containerized development environment!**
