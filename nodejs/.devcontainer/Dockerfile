FROM mcr.microsoft.com/devcontainers/javascript-node:1-22-bookworm

# Install common tools and Fish shell
RUN apt-get update && apt-get install -y \
    fish \
    vim \
    git \
    tig \
    telnet \
    htop \
    tree \
    curl \
    wget \
    jq \
    nano \
    less \
    tmux \
    screen \
    zip \
    unzip \
    redis-tools \
    netcat-traditional \
    dnsutils \
    iputils-ping \
    traceroute \
    tcpdump \
    strace \
    lsof \
    dos2unix \
    software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install modern Git tools
# Install Delta (better git diff) - always latest
RUN DELTA_VERSION=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep -Po '"tag_name": "\K.*?(?=")') \
    && curl -sL "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_amd64.deb" -o /tmp/git-delta.deb \
    && dpkg -i /tmp/git-delta.deb \
    && rm /tmp/git-delta.deb

# Install Lazygit (git TUI) - always latest
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') \
    && curl -sL "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" | tar -xz -C /usr/local/bin lazygit

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh git-extras \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy post-create setup script
COPY post-create-setup.sh /tmp/post-create-setup.sh
RUN dos2unix /tmp/post-create-setup.sh
RUN chmod +x /tmp/post-create-setup.sh

# Switch to the node user (default user in javascript-node base image)
USER node

# Install Fisher (Fish plugin manager) using the standard method
RUN fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"

# Install essential Fish plugins (with fallback if they fail)
RUN fish -c "fisher install jorgebucaran/autopair.fish" || true
RUN fish -c "fisher install jethrokuan/z" || true  
RUN fish -c "fisher install oh-my-fish/theme-bobthefish" || true
# Install git aliases plugin - provides comprehensive git abbreviations
RUN fish -c "fisher install jhillyerd/plugin-git" || true
# Install additional useful plugins
RUN fish -c "fisher install franciscolourenco/done" || true
RUN fish -c "fisher install PatrickF1/fzf.fish" || true
# Ensure bass is available for NVM integration in Fish
RUN fish -c "fisher install edc/bass" || true

# Install additional package managers
USER root
# Install pnpm
RUN npm install -g pnpm

# Install Yarn using npm (more reliable method)
RUN npm install -g yarn

USER node

# Configure Fish shell with useful settings (after plugin installation)
RUN echo '# Fish configuration' > ~/.config/fish/config.fish \
    && echo '' >> ~/.config/fish/config.fish \
    && echo '# Set environment variables' >> ~/.config/fish/config.fish \
    && echo 'set -gx EDITOR vim' >> ~/.config/fish/config.fish \
    && echo 'set -gx VISUAL vim' >> ~/.config/fish/config.fish \
    && echo '' >> ~/.config/fish/config.fish \
    && echo '# Git aliases provided by jhillyerd/plugin-git plugin' >> ~/.config/fish/config.fish \
    && echo '# Available aliases include: gst, gd, ga, gc, gp, gl, gco, glog, etc.' >> ~/.config/fish/config.fish \
    && echo '# Use "abbr --list | grep git" to see all available git abbreviations' >> ~/.config/fish/config.fish \
    && echo '' >> ~/.config/fish/config.fish \
    && echo '# Modern tool aliases' >> ~/.config/fish/config.fish \
    && echo 'alias lg "lazygit"' >> ~/.config/fish/config.fish \
    && echo '' >> ~/.config/fish/config.fish \
    && echo '# Package manager shortcuts' >> ~/.config/fish/config.fish \
    && echo 'alias pn "pnpm"' >> ~/.config/fish/config.fish \
    && echo 'alias yr "yarn"' >> ~/.config/fish/config.fish \
    && echo '' >> ~/.config/fish/config.fish \
    && echo '# SSH Agent configuration' >> ~/.config/fish/config.fish \
    && echo 'if test -z "$SSH_AUTH_SOCK"' >> ~/.config/fish/config.fish \
    && echo '    eval (ssh-agent -c)' >> ~/.config/fish/config.fish \
    && echo '    ssh-add ~/.ssh/id_rsa 2>/dev/null' >> ~/.config/fish/config.fish \
    && echo 'end' >> ~/.config/fish/config.fish \
    && echo '' >> ~/.config/fish/config.fish \
    && echo '# NVM configuration for Fish' >> ~/.config/fish/config.fish \
    && echo 'function nvm' >> ~/.config/fish/config.fish \
    && echo '    bass source ~/.nvm/nvm.sh --no-use ';' nvm $argv' >> ~/.config/fish/config.fish \
    && echo 'end' >> ~/.config/fish/config.fish \
    && echo '' >> ~/.config/fish/config.fish \
    && echo '# Auto-load nvm on Fish start' >> ~/.config/fish/config.fish \
    && echo 'nvm use default --silent 2>/dev/null' >> ~/.config/fish/config.fish \
    && echo '' >> ~/.config/fish/config.fish \
    && echo '# Welcome message' >> ~/.config/fish/config.fish \
    && echo 'function fish_greeting' >> ~/.config/fish/config.fish \
    && echo '    echo "🚀 Node.js Dev Container Ready!"' >> ~/.config/fish/config.fish \
    && echo '    echo "📦 Available package managers: npm, yarn, pnpm"' >> ~/.config/fish/config.fish \
    && echo '    echo "🔧 Git tools: lazygit (lg), delta diff, GitHub CLI (gh), git aliases via plugin"' >> ~/.config/fish/config.fish \
    && echo '    echo "🐟 Fish shell with Fisher plugins loaded"' >> ~/.config/fish/config.fish \
    && echo 'end' >> ~/.config/fish/config.fish

# Configure vim with basic settings
RUN echo 'syntax on' > ~/.vimrc \
    && echo 'set number' >> ~/.vimrc \
    && echo 'set relativenumber' >> ~/.vimrc \
    && echo 'set autoindent' >> ~/.vimrc \
    && echo 'set smartindent' >> ~/.vimrc \
    && echo 'set tabstop=2' >> ~/.vimrc \
    && echo 'set shiftwidth=2' >> ~/.vimrc \
    && echo 'set expandtab' >> ~/.vimrc \
    && echo 'set showmatch' >> ~/.vimrc \
    && echo 'set hlsearch' >> ~/.vimrc \
    && echo 'set incsearch' >> ~/.vimrc \
    && echo 'set ignorecase' >> ~/.vimrc \
    && echo 'set smartcase' >> ~/.vimrc \
    && echo 'set mouse=a' >> ~/.vimrc \
    && echo 'set clipboard=unnamedplus' >> ~/.vimrc \
    && echo 'colorscheme desert' >> ~/.vimrc

# Configure git with useful defaults and Delta
RUN git config --global init.defaultBranch main \
    && git config --global pull.rebase false \
    && git config --global core.editor vim \
    && git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit" \
    && git config --global core.pager "delta" \
    && git config --global interactive.diffFilter "delta --color-only" \
    && git config --global delta.navigate true \
    && git config --global delta.light false \
    && git config --global delta.side-by-side true \
    && git config --global merge.conflictstyle "diff3" \
    && git config --global diff.colorMoved "default"

# Set the default shell to fish
USER root
RUN chsh -s /usr/bin/fish node

USER node