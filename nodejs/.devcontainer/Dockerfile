FROM mcr.microsoft.com/devcontainers/javascript-node:1-22-bookworm

# Install common tools
RUN apt-get update && apt-get install -y \
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy post-create setup script
COPY post-create-setup.sh /tmp/post-create-setup.sh
RUN dos2unix /tmp/post-create-setup.sh
RUN chmod +x /tmp/post-create-setup.sh

# Switch to the node user (default user in javascript-node base image)
USER node

# Install oh-my-zsh for the node user
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended || true

# Install oh-my-zsh plugins
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions

# Configure .zshrc with useful settings
RUN sed -i 's/ZSH_THEME="devcontainers"/ZSH_THEME="af-magic"/' ~/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git node npm docker docker-compose zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' ~/.zshrc \
    && echo '' >> ~/.zshrc \
    && echo '# Custom aliases' >> ~/.zshrc \
    && echo 'alias ll="ls -alF"' >> ~/.zshrc \
    && echo 'alias la="ls -A"' >> ~/.zshrc \
    && echo 'alias l="ls -CF"' >> ~/.zshrc \
    && echo 'alias ..="cd .."' >> ~/.zshrc \
    && echo 'alias ...="cd ../.."' >> ~/.zshrc \
    && echo 'alias grep="grep --color=auto"' >> ~/.zshrc \
    && echo 'alias fgrep="fgrep --color=auto"' >> ~/.zshrc \
    && echo 'alias egrep="egrep --color=auto"' >> ~/.zshrc \
    && echo '' >> ~/.zshrc \
    && echo '# Custom environment variables' >> ~/.zshrc \
    && echo 'export EDITOR=vim' >> ~/.zshrc \
    && echo 'export VISUAL=vim' >> ~/.zshrc \
    && echo '' >> ~/.zshrc \
    && echo '# SSH Agent configuration' >> ~/.zshrc \
    && echo 'if [ -z "$SSH_AUTH_SOCK" ]; then' >> ~/.zshrc \
    && echo '    eval "$(ssh-agent -s)"' >> ~/.zshrc \
    && echo '    ssh-add ~/.ssh/id_rsa 2>/dev/null' >> ~/.zshrc \
    && echo 'fi' >> ~/.zshrc

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

# Configure git with useful defaults
RUN git config --global init.defaultBranch main \
    && git config --global pull.rebase false \
    && git config --global core.editor vim \
    && git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Set the default shell to zsh
USER root
RUN chsh -s /bin/zsh node

USER node