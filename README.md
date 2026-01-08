# DevContainer Templates

Pre-configured development containers for different technology stacks.

## Available Environments

- **[Node.js](nodejs/)** - Node.js 22 LTS with npm, ESLint, Prettier, and development tools
- **.NET** - .NET 8.0 SDK with C# tooling and ASP.NET Core support (dotnet/ folder)


## Quick Start

1. **Prerequisites:** VS Code with Dev Containers extension, Docker Desktop running
2. **Choose environment:** Open `nodejs/` or `dotnet/` folder in VS Code
3. **Rebuild container:** Press `Ctrl+Shift+P` → "Dev Containers: Rebuild and Reopen in Container"
4. **Follow setup:** See the environment's README.md for configuration options

### 🐳 **Docker Desktop Prerequisites:**

- Docker Desktop must be running on your host machine
- Enable "Expose daemon on tcp://localhost:2375 without TLS" in Docker Desktop settings
- Disable Resource Saver feature to ensure containers run smoothly, otherwise you may face VS Code unexpected shutdowns.

## Project Structure

```
DevContainer/
├── nodejs/                     # Node.js development environment
│   ├── .devcontainer/
│   │   ├── .ssh-keys-template.example  # Safe SSH template (committed)
│   │   ├── devcontainer.json   # VS Code dev container config
│   │   ├── Dockerfile          # Container definition
│   │   ├── setup-ssh-dotenv.sh # SSH setup script
│   │   └── post-create-setup.sh # Post-creation setup
│   └── README.md               # Node.js setup instructions
├── dotnet/                     # .NET development environment
│   ├── .devcontainer/
│   │   ├── .ssh-keys-template.example  # Safe SSH template (committed)
│   │   ├── devcontainer.json   # VS Code dev container config
│   │   ├── Dockerfile          # Container definition
│   │   ├── setup-ssh-dotenv.sh # SSH setup script
│   │   └── post-create-setup.sh # Post-creation setup
│   └── README.md               # .NET setup instructions
├── .gitignore                  # Git ignore rules
└── README.md                   # This file
```

## Security

- **SSH Keys:** Use `.ssh-keys-template.example` as a safe, committed template. Real keys go in `.ssh-keys-template` (in `.gitignore`)
- **Environment Files:** `.env` files contain sensitive data and are automatically ignored
- **Non-root:** Containers run with non-root users

For details, see your environment's README.md

## Adding New Environments

To add a new technology stack:

1. Create a new folder (e.g., `python/`, `go/`, etc.)
2. Copy and adapt the structure from an existing environment
3. Update the base image and dependencies in `Dockerfile`
4. Modify `devcontainer.json` for appropriate extensions
5. Adapt `post-create-setup.sh` for the new stack
6. Create stack-specific documentation in the folder's `README.md`
7. Update this root README.md
