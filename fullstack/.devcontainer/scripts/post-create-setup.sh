#!/bin/bash

# Comprehensive post-creation setup script for DevContainer
# This script merges all post-creation functionality into one script with proper error handling

# Set strict error handling
set -euo pipefail
IFS=$'\n\t'

# Color codes for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log messages with timestamps and colors
log_info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO:${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] SUCCESS:${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" >&2
}

# Function to handle errors
handle_error() {
    local exit_code=$?
    local line_no=$1
    log_error "An error occurred in line $line_no. Exit code: $exit_code"
    log_error "Setup failed. Please check the logs above for details."
    exit $exit_code
}

# Set up error trap
trap 'handle_error $LINENO' ERR

echo "🚀 Starting comprehensive DevContainer post-creation setup..."
echo "=================================================="

# Function to setup SSH keys
setup_ssh_keys() {
    log_info "Starting SSH setup..."
    
    # Create .ssh directory
    mkdir -p ~/.ssh
    
    local private_key_b64="$1"
    local public_key_b64="$2"
    
    # Setup SSH keys from base64 encoded environment variables
    if [ -n "$private_key_b64" ] && [ -n "$public_key_b64" ]; then
        log_info "Setting up SSH keys from base64 encoded environment variables..."
        
        # Decode and save private key
        if ! echo "$private_key_b64" | base64 -d > ~/.ssh/id_rsa 2>/dev/null; then
            log_error "Failed to decode private key. Please check SSH_PRIVATE_KEY_B64 environment variable."
            return 1
        fi
        
        # Decode and save public key
        if ! echo "$public_key_b64" | base64 -d > ~/.ssh/id_rsa.pub 2>/dev/null; then
            log_error "Failed to decode public key. Please check SSH_PUBLIC_KEY_B64 environment variable."
            return 1
        fi
        
        # Set proper permissions
        chmod 600 ~/.ssh/id_rsa
        chmod 644 ~/.ssh/id_rsa.pub
        
        # Validate key format
        if ! ssh-keygen -l -f ~/.ssh/id_rsa.pub >/dev/null 2>&1; then
            log_error "Invalid SSH public key format detected."
            return 1
        fi
        
        log_success "SSH keys set up successfully from base64 encoded environment variables."
        return 0
    fi
    
    log_warning "No SSH keys found in environment variables."
    log_warning "SSH key authentication will not be available."
    echo "To add SSH keys:"
    echo "  1. Run: ./.devcontainer/setup-ssh-dotenv.sh"
    echo "  2. Or copy template: cp ./.devcontainer/.ssh-keys-template.example ./.devcontainer/.ssh-keys-template"
    echo "  3. Edit the template with your keys and run the setup script"
    return 1
}

# Function to setup SSH configuration
setup_ssh_config() {
    log_info "Setting up known hosts..."
    
    # Setup known hosts for common Git providers
    local hosts=("github.com" "gitlab.com" "bitbucket.org" "ssh.dev.azure.com")
    for host in "${hosts[@]}"; do
        if ssh-keyscan "$host" >> ~/.ssh/known_hosts 2>/dev/null; then
            log_info "Added $host to known hosts"
        else
            log_warning "Failed to add $host to known hosts (may be offline)"
        fi
    done
    
    # Configure SSH client
    log_info "Configuring SSH client..."
    cat > ~/.ssh/config << 'EOF'
Host *
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_rsa
    ServerAliveInterval 60
    ServerAliveCountMax 3
    StrictHostKeyChecking no
    UserKnownHostsFile ~/.ssh/known_hosts
EOF
    chmod 600 ~/.ssh/config
    
    log_success "SSH configuration completed!"
}

# Function to setup Node.js with nvm
setup_nodejs() {
    log_info "Setting up Node.js LTS versions..."
    
    # Check if nvm is available
    if [ ! -s "$NVM_DIR/nvm.sh" ]; then
        log_error "NVM not found at $NVM_DIR/nvm.sh"
        return 1
    fi
    
    # Source nvm to make it available in this script
    # shellcheck source=/dev/null
    source "$NVM_DIR/nvm.sh"
    
    # Install Node.js 22 LTS
    log_info "Installing Node.js 22 LTS (Jod)..."
    if ! nvm install 22 --lts --latest-npm; then
        log_error "Failed to install Node.js 22 LTS"
        return 1
    fi
    log_success "Node.js 22 LTS installed"
    
    # Set Node.js 22 as the default version
    log_info "Setting Node.js 22 LTS as default..."
    if ! nvm alias default 22; then
        log_error "Failed to set Node.js 22 as default"
        return 1
    fi
    
    if ! nvm use default; then
        log_error "Failed to use Node.js 22 as current version"
        return 1
    fi
    
    # Show installed versions
    log_info "Installed Node.js versions:"
    nvm list || log_warning "Could not list Node.js versions"
    
    # Verify installation
    local node_version
    node_version=$(node --version 2>/dev/null || echo "unknown")
    log_success "Node.js setup completed! Current version: $node_version"
}

# Function to test SQL Server connection
test_sql_server_connection() {
    log_info "Testing SQL Server connection..."
    
    # Load SA_PASSWORD from .env file if it exists
    local env_file=".devcontainer/.env"
    if [ -f "$env_file" ]; then
        # Export variables from .env file, excluding comments and empty lines
        set -a
        # shellcheck source=/dev/null
        source <(grep -v '^#' "$env_file" | grep -v '^$')
        set +a
    fi
    
    local sa_password="${MSSQL_SA_PASSWORD:-}"
    
    if [ -z "$sa_password" ]; then
        log_warning "SQL Server SA_PASSWORD is not set."
        log_warning "Please set the MSSQL_SA_PASSWORD in .devcontainer/.env"
        return 1
    fi
    
    # Create test SQL file
    local test_sql_file="testsqlconnection.sql"
    echo "SELECT * FROM SYS.DATABASES" > "$test_sql_file"
    
    log_info "Waiting for SQL Server to be ready (timeout: 30 attempts)..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log_info "Connection attempt $attempt/$max_attempts..."
        
        if output=$(sqlcmd -S localhost -U sa -P "$sa_password" -d master -i "$test_sql_file" 2>&1); then
            log_success "SQL Server is ready and accepting connections!"
            rm -f "$test_sql_file"
            return 0
        else
            if [ $attempt -eq $max_attempts ]; then
                log_error "Failed to connect to SQL Server after $max_attempts attempts."
                log_error "Last error output:"
                echo "$output" >&2
                rm -f "$test_sql_file"
                return 1
            fi
            log_info "Not ready yet... (attempt $attempt/$max_attempts)"
            sleep 1
        fi
        
        ((attempt++))
    done
}

# Function to verify dependencies
verify_dependencies() {
    log_info "Verifying required dependencies..."
    
    local missing_deps=()
    
    # Check for required commands
    local required_commands=("base64" "ssh-keygen" "ssh-keyscan" "sqlcmd")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_error "Please ensure all required tools are installed."
        return 1
    fi
    
    log_success "All required dependencies are available."
}

# Function to handle database-specific setup
setup_database_project() {
    local dacpath="$1"
    
    if [ -n "$dacpath" ]; then
        log_info "Processing database project path: $dacpath"
        
        # Extract the project directory from the dacpath
        local projectDir
        projectDir=$(echo "$dacpath" | cut -d'/' -f1-2)
        log_info "Project directory: $projectDir"
        
        # Additional database-specific setup could go here
        # For example: database migrations, seed data, etc.
        log_success "Database project path processed successfully"
    else
        log_info "No database project path provided, skipping database-specific setup"
    fi
}

# Main execution
main() {
    local exit_code=0
    local dacpath="${1:-}"
    
    log_info "Starting DevContainer post-create setup..."
    if [ -n "$dacpath" ]; then
        log_info "Database project path: $dacpath"
    fi
    
    # Verify dependencies first
    if ! verify_dependencies; then
        exit_code=1
    fi
    
    # Setup SSH (non-critical, can continue without it)
    if ! setup_ssh_keys "${SSH_PRIVATE_KEY_B64:-}" "${SSH_PUBLIC_KEY_B64:-}"; then
        log_warning "SSH key setup failed or skipped"
    fi
    
    # Setup SSH configuration regardless of key setup
    if ! setup_ssh_config; then
        log_warning "SSH configuration setup failed"
        exit_code=1
    fi
    
    # Setup Node.js (non-critical for SQL-focused development)
    if ! setup_nodejs; then
        log_warning "Node.js setup failed"
        exit_code=1
    fi
    
    # Test SQL Server connection (critical for this DevContainer)
    if ! test_sql_server_connection; then
        log_warning "SQL Server connection test failed"
        log_warning "The container may still work, but database connectivity issues may occur"
        exit_code=1
    fi
    
    # Handle database-specific setup
    setup_database_project "$dacpath"
    
    echo ""
    echo "=================================================="
    if [ $exit_code -eq 0 ]; then
        log_success "🎉 All setup tasks completed successfully!"
    else
        log_warning "⚠️ Setup completed with some warnings or failures."
        log_warning "Please review the log messages above for details."
        log_warning "The DevContainer may still be functional for basic development."
    fi
    echo "=================================================="
    
    # Exit with success to not block container creation, but log any issues
    exit 0
}

# Run main function with all arguments
main "$@"