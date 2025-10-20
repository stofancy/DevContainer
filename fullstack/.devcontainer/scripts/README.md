# DevContainer Setup Scripts

This directory contains the setup scripts for the DevContainer environment.

## Overview

The setup process has been consolidated into a comprehensive script that handles all post-creation tasks with proper error handling and clear logging.

## Scripts

### `post-create-setup.sh`
The single comprehensive setup script that handles all post-creation tasks:
- **SSH Key Setup**: Configures SSH keys from environment variables
- **SSH Configuration**: Sets up known hosts and SSH client configuration
- **Node.js Setup**: Installs and configures Node.js LTS versions using nvm
- **SQL Server Testing**: Tests SQL Server connectivity
- **Database Project Setup**: Handles database-specific setup with dacpath parameter
- **Error Handling**: Provides clear error messages and continues setup when possible

### `validate-setup.sh`
Validation script to test all setup components after container creation.

### `installSQLtools.sh`
SQL tools installation script (called during Docker build, not post-creation).

## Features

### Enhanced Error Handling
- **Strict Error Handling**: Uses `set -euo pipefail` for robust error detection
- **Error Traps**: Captures and reports errors with line numbers
- **Graceful Degradation**: Continues setup when non-critical components fail
- **Clear Logging**: Color-coded, timestamped log messages

### SSH Setup
- Validates base64-encoded SSH keys from environment variables
- Sets up SSH configuration for common Git providers
- Provides clear instructions when SSH keys are missing
- Validates SSH key formats before use

### SQL Server Integration
- Tests SQL Server connectivity with retry logic
- Loads configuration from `.env` file
- Provides detailed error messages for connection failures
- Non-blocking: continues setup even if SQL Server is not ready

### Node.js Setup
- Installs Node.js 22 LTS with latest npm
- Sets up default Node.js version
- Validates installation

## Usage

The script is automatically called during DevContainer creation via the `postCreateCommand` in `devcontainer.json`.

### Manual Execution
If you need to run the setup manually:

```bash
# Run the comprehensive setup (without database project)
bash .devcontainer/scripts/post-create-setup.sh

# Run with database project path
bash .devcontainer/scripts/post-create-setup.sh "database/Library/bin/Debug"
```

### SSH Key Setup
To set up SSH keys:

1. Run the SSH setup helper:
   ```bash
   bash .devcontainer/setup-ssh-dotenv.sh
   ```

2. Or manually create the environment variables in `.devcontainer/.env`:
   ```
   SSH_PRIVATE_KEY_B64=<base64-encoded-private-key>
   SSH_PUBLIC_KEY_B64=<base64-encoded-public-key>
   ```

## Troubleshooting

### Common Issues

**SSH Keys Not Working**
- Verify `SSH_PRIVATE_KEY_B64` and `SSH_PUBLIC_KEY_B64` are set in `.devcontainer/.env`
- Ensure keys are properly base64 encoded
- Check key format with `ssh-keygen -l -f ~/.ssh/id_rsa.pub`

**SQL Server Connection Failed**
- Verify `MSSQL_SA_PASSWORD` is set in `.devcontainer/.env`
- Check if SQL Server container is running
- Wait longer for SQL Server to initialize (first startup can be slow)

**Node.js Installation Failed**
- Check if nvm is properly installed
- Verify internet connectivity for downloading Node.js

### Log Analysis
All setup activities are logged with timestamps and color coding:
- 🔵 **INFO**: General information
- 🟢 **SUCCESS**: Successful operations
- 🟡 **WARNING**: Non-critical issues
- 🔴 **ERROR**: Critical failures

## Configuration

The setup scripts read configuration from:
- `.devcontainer/.env` - Environment variables
- `devcontainer.json` - Container configuration
- `docker-compose.yml` - Service definitions

## Best Practices

1. **Always rebuild the container** after changing SSH keys or environment variables
2. **Check logs** if setup fails to identify specific issues
3. **Use the SSH setup helper** rather than manually encoding keys
4. **Test SQL connectivity** after container startup if database features are needed
