# Dev Container Setup

This dev container provides a fully configured Node.js development environment with SSH keys support.

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
- Node.js environment
- Development tools
- VS Code extensions

## SSH Keys Setup

To use SSH keys for Git operations and other SSH-based tasks in the dev container:

### Simple Template-Based Setup

1. **Edit the template file** with your SSH keys:
   ```bash
   # Edit this file with your actual SSH keys
   ./nodejs/.ssh-keys-template
   ```

2. **Run the setup script**:
   ```bash
   ./nodejs/setup-ssh-dotenv.sh
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

### Security Notes

- The template file is automatically deleted after processing for security
- SSH keys are base64-encoded before being stored in the `.env` file
- The `.env` file is already in `.gitignore` to prevent accidental commits

## What's Included

- Node.js with npm and essential tools
- Git configuration
- SSH client with automatic key setup
- ESLint and Prettier pre-configured
- VS Code extensions for JavaScript/Node.js development

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
2. Run the setup script: `./nodejs/setup-ssh-dotenv.sh`
3. Rebuild the container after creating the `.env` file

### Extensions Not Loading
1. Make sure you're connected to the container (check the green status bar)
2. Extensions are automatically installed during container creation
3. If missing, reload the window: `Ctrl+Shift+P` → "Developer: Reload Window"

## Manual Commands

If you prefer using the command line:

```bash
# Build the container
docker build -t node-devcontainer nodejs/

# Run with volume mounts (VS Code handles this automatically)
docker run -it --rm -v "$(pwd)":/workspace node-devcontainer
```
