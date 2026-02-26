FROM mcr.microsoft.com/devcontainers/javascript-node:24-bookworm

# Install common tools, .NET SDK (LTS), and GitHub CLI
RUN apt-get update \
    && apt-get install -y \
        ca-certificates \
        gnupg \
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
        fzf \
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
    && wget -qO /tmp/packages-microsoft-prod.deb https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb \
    && dpkg -i /tmp/packages-microsoft-prod.deb \
    && rm /tmp/packages-microsoft-prod.deb \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y dotnet-sdk-8.0 gh git-extras \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install modern Git tools
# Install Delta (better git diff) - pinned version (update periodically)
# Latest as of Feb 2026: https://github.com/dandavison/delta/releases
ENV DELTA_VERSION=0.18.2
RUN echo "Installing Delta version: ${DELTA_VERSION}" \
    && curl -fsSL "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_amd64.deb" -o /tmp/git-delta.deb \
    && dpkg -i /tmp/git-delta.deb \
    && rm /tmp/git-delta.deb

# Install Lazygit (git TUI) - pinned version (update periodically)
# Latest as of Feb 2026: https://github.com/jesseduffield/lazygit/releases
ENV LAZYGIT_VERSION=0.59.0
RUN echo "Installing Lazygit version: ${LAZYGIT_VERSION}" \
    && curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" | tar -xz -C /usr/local/bin lazygit

# Copy post-create setup script
COPY post-create-setup.sh /tmp/post-create-setup.sh
RUN dos2unix /tmp/post-create-setup.sh
RUN chmod +x /tmp/post-create-setup.sh

# Switch to the node user (default user in javascript-node base image)
USER node

# Install NVM for the node user (latest)
ENV NVM_DIR=/home/node/.nvm
RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash \
    && bash -lc "source $NVM_DIR/nvm.sh && nvm alias default system"

# Install Fisher (Fish plugin manager) using the standard method
RUN fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"

# Install essential Fish plugins (with fallback if they fail)
RUN fish -c "fisher install jorgebucaran/autopair.fish" || true
RUN fish -c "fisher install jethrokuan/z" || true
# Install git aliases plugin - provides comprehensive git abbreviations
RUN fish -c "fisher install jhillyerd/plugin-git" || true
# Install additional useful plugins
RUN fish -c "fisher install franciscolourenco/done" || true
RUN fish -c "fisher install PatrickF1/fzf.fish" || true
# Ensure bass is available for NVM integration in Fish
RUN fish -c "fisher install edc/bass" || true
RUN fish -c "fisher install IlanCosman/tide@v6" || true
RUN fish -c "tide configure --auto" || true

# Install additional package managers
USER root
# Install pnpm
RUN npm install -g pnpm

# Install Yarn using npm (more reliable method)
RUN npm install -g yarn

USER node

# Copy and run Fish config setup script
COPY setup-fish-config.sh /tmp/setup-fish-config.sh
USER root
RUN chmod +x /tmp/setup-fish-config.sh
USER node
RUN /tmp/setup-fish-config.sh

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