# Node.js Dev Container

Quick, automated development environment with Node.js 22, modern tools, and VS Code integration.

## ⚡ Quick Start

### Option A: No SSH (3-5 min)
```bash
Ctrl+Shift+P → "Dev Containers: Rebuild and Reopen in Container"
# Wait for build... Done!
```

### Option B: With SSH (4-6 min)
```bash
cp .devcontainer/.ssh-keys-template.example .devcontainer/.ssh-keys-template
# Edit template with your SSH keys from ~/.ssh/id_rsa and ~/.ssh/id_rsa.pub
.devcontainer/setup-ssh-dotenv.sh
Ctrl+Shift+P → "Dev Containers: Rebuild Container"
```

### Start Coding
```bash
node --version          # Verify Node.js 22
npm install <package>   # Install dependencies
npm start              # Start your app
```

---

## 📦 What's Included

Node.js 22 LTS, npm, yarn, pnpm, NVM, Fish shell with plugins (z, fzf, autopair), git tools (delta, lazygit, GitHub CLI), Docker client, ESLint, Prettier, Vim, VS Code extensions (Prettier, ESLint, GitLens, Copilot).

---

## 📖 Common Commands

```bash
# Node versions
nvm list                    # Show installed versions
nvm install 20              # Install version 20
nvm use 20                  # Switch version

# Git
git clone <repo>
git lg                      # Pretty log
lg                          # Open lazygit UI
gh pr create                # Create PR

# Package managers
npm install <pkg>
yarn add <pkg>
pnpm add <pkg>

# Search & navigation
fzf                         # Find files
z <dir>                     # Jump to directory

# Docker
docker build -t my-img .
docker ps
```

---

## ⚙️ Environment Configuration

### Option 1: Using `.env` File (Simple)

Create `.devcontainer/.env` for git identity and npm tokens:
```bash
GIT_USER_NAME="Your Name"
GIT_USER_EMAIL="your@email.com"
NPM_TOKEN="your_npm_token"
```

The `.env` file is:
- Automatically loaded by container
- Git-ignored (safe to store secrets)
- Read by post-create-setup.sh script

**Note:** SSH keys are NOT added here. Use the SSH Setup process below.

### Option 2: Using Host Environment Variables (Advanced)

Add to your host shell (`.bashrc`, `.zshrc`, `.env`, etc.):
```bash
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="your@email.com"
export NPM_TOKEN="your_npm_token"
```

Then they're automatically forwarded to the container (see `containerEnv` in `devcontainer.json`).

**Note:** SSH keys are NOT set this way. Use the SSH Setup process below.

---

## 🔐 SSH Setup (Only via Script)

SSH keys MUST be set up using the automatic setup process:

### Automatic SSH Setup (Recommended)
```bash
# 1. Copy template
cp .devcontainer/.ssh-keys-template.example .devcontainer/.ssh-keys-template

# 2. Edit with your SSH keys
# ~/.ssh/id_rsa → PRIVATE_KEY
# ~/.ssh/id_rsa.pub → PUBLIC_KEY

# 3. Run script (creates .env, deletes template)
.devcontainer/setup-ssh-dotenv.sh

# 4. Rebuild container
Ctrl+Shift+P → "Dev Containers: Rebuild Container"
```

This script:
- Reads SSH keys from template file
- Base64-encodes them automatically
- Writes SSH_PRIVATE_KEY_B64 and SSH_PUBLIC_KEY_B64 to `.env`
- Deletes template file (security)
- post-create-setup.sh decodes and sets up SSH automatically

**Do NOT manually add SSH keys to .env - use the script!**

---

## 🆘 Troubleshooting

| Problem | Solution |
|---------|----------|
| **Build fails** | Docker Desktop running? 4GB+ disk space free? Try rebuild without cache: `Ctrl+Shift+P` → "Dev Containers: Rebuild Container (No Cache)" |
| **SSH not working** | Did you use setup-ssh-dotenv.sh? Rebuild container, verify: `ssh-add -l` |
| **Extensions missing** | Verify connected to container (green indicator, bottom-left), reload: `Ctrl+Shift+P` → "Developer: Reload Window" |
| **Docker fails** | Docker Desktop running? Test: `docker ps`. Check Docker Settings → Advanced → "Expose daemon on tcp://localhost:2375 without TLS" |
| **Git user not set** | Did you create .env or set host variables? Check GIT_USER_NAME and GIT_USER_EMAIL |
| **NPM auth fails** | Did you set NPM_TOKEN in .env or host environment? |

---

## 📁 Shared Workspaces (Optional)

Files in `/home/node/workspaces` persist across rebuilds:
```bash
cd ~/workspaces
# Clone repos or projects here to keep them safe
```

---

## 🔗 More Help

- Dev Containers: https://containers.dev/
- Node.js: `node --version`
- Fish shell: `fish_help` (inside container)
- GitHub CLI: `gh help`
