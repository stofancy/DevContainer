# Node.js Dev Container

This dev container provides a fully configured Node.js development environment with modern shell (Fish), shared persistent workspace volume, and automated Git identity configuration.

## Quick Start Guide

### 1. Prerequisites

- VS Code with the Dev Containers extension installed
- Docker Desktop running on your machine

### 2. Build and Open Dev Container

#### Option A: Command Palette (Recommended)

1. Open VS Code in this workspace folder
2. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
3. Type "Dev Containers: Rebuild and Reopen in Container"
4. Select it and wait for the container to build

#### Option B: Notification Popup

1. Open VS Code in this workspace folder
2. VS Code should show a popup asking "Reopen in Container"
3. Click "Reopen in Container"

#### Option C: Status Bar

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

1. **Copy and edit the template file** with your SSH keys:

   ```bash
   # Copy the example template
   cp ./nodejs/.ssh-keys-template.example ./nodejs/.ssh-keys-template
   
   # Edit this file with your actual SSH keys
   # Your keys are typically in ~/.ssh/id_rsa and ~/.ssh/id_rsa.pub
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

**Note:** Copy from `.ssh-keys-template.example` to get started, then replace the placeholder content with your actual SSH keys.

### Security Notes

- Copy `.ssh-keys-template.example` to `.ssh-keys-template` and edit with your real keys
- The template file `.ssh-keys-template` is automatically deleted after processing for security
- SSH keys are base64-encoded before being stored in the `.env` file
- The `.env` file is already in `.gitignore` to prevent accidental commits
- The `.ssh-keys-template` file is also in `.gitignore` to prevent committing real SSH keys

## What's Included

- Node.js 22 LTS via devcontainers base image
- npm, yarn (via npm), pnpm installed globally
- Fish shell with Fisher plugin manager and core plugins (autopair, z navigation, bobthefish theme)
- Git tooling: delta (diff viewer), lazygit (TUI), GitHub CLI, git-extras
- Shared persistent volume mounted at `/home/node/workspaces` (named `devcontainer-shared-workspaces`)
- Automatic Git identity configuration via `.env` values `GIT_USER_NAME`, `GIT_USER_EMAIL`
- SSH client with automatic key setup
- ESLint & Prettier ready to use
- VS Code recommended extensions installed automatically

## Shared Workspaces Volume

A named Docker volume `devcontainer-shared-workspaces` is mounted at `/home/node/workspaces` so data remains across container rebuilds and can be shared with other stacks (.NET, fullstack). Place repos or cross-project assets there if you want persistence across environments.

To list its contents from host:

```bash
docker run --rm -v devcontainer-shared-workspaces:/data alpine ls -la /data | head
```

To back it up:

```bash
docker run --rm -v devcontainer-shared-workspaces:/data -v "$PWD":/backup alpine tar -czf /backup/workspaces-backup.tgz -C /data .
```

## Git Identity Configuration

Set your identity in `.devcontainer/.env` before (re)building:

```bash
GIT_USER_NAME="Parker An"
GIT_USER_EMAIL="parker.an@serko.com"
```
If unset, falls back to `NPM_IDENT` or a generic placeholder. Adjust at any time:

```bash
git config --global user.name "New Name"
git config --global user.email "new.email@example.com"
```

Delta is configured as pager; view a graph log:

```bash
git lg
```

## Troubleshooting

### Container Won't Build

1. Make sure Docker Desktop is running
2. Check if you have sufficient disk space
3. Try rebuilding without cache: `Ctrl+Shift+P` → "Dev Containers: Rebuild Container (No Cache)"
4. Error `docker: open ../.env: The system cannot find the file specified.` means the env-file path was wrong. Ensure `.env` exists at `./nodejs/.env` (workspace root) or remove the `runArgs` env-file entry from `devcontainer.json` if you don't need it.

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
# Build the devcontainer image manually (normally VS Code handles this)
docker build -f nodejs/.devcontainer/Dockerfile -t nodejs-devcontainer nodejs/.devcontainer

# Run with shared workspace volume
docker run -it --rm \
   -v devcontainer-shared-workspaces:/home/node/workspaces \
   -v "$(pwd)":/workspace nodejs-devcontainer fish

# Run with env file (if present)
docker run -it --rm \
   --env-file nodejs/.env \
   -v devcontainer-shared-workspaces:/home/node/workspaces \
   -v "$(pwd)":/workspace nodejs-devcontainer fish
```
