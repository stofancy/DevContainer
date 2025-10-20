#!/bin/bash

# Vim Configuration Setup for DevContainer
# Provides a modern Vim experience for development work

set -euo pipefail

# Color codes
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log_info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO:${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] SUCCESS:${NC} $1"
}

echo "🔧 Setting up Vim configuration..."
echo "=================================="

VSCODE_USER="vscode"
VIM_CONFIG_DIR="/home/$VSCODE_USER/.vim"
VIMRC_FILE="/home/$VSCODE_USER/.vimrc"

# Create Vim configuration directory
log_info "Creating Vim configuration directories..."
mkdir -p "$VIM_CONFIG_DIR/autoload"
mkdir -p "$VIM_CONFIG_DIR/bundle"
mkdir -p "$VIM_CONFIG_DIR/colors"

# Install vim-plug (Vim plugin manager)
log_info "Installing vim-plug plugin manager..."
curl -fLo "$VIM_CONFIG_DIR/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Create a comprehensive .vimrc for development
log_info "Creating Vim configuration..."
cat > "$VIMRC_FILE" << 'EOF'
" Vim Configuration for DevContainer Development
" Optimized for Node.js, Python, .NET, and general development

" ============================================================================
" Basic Settings
" ============================================================================
set nocompatible              " Disable Vi compatibility
set encoding=utf-8            " Set encoding
set fileencoding=utf-8        " File encoding
set number                    " Show line numbers
set relativenumber            " Show relative line numbers
set cursorline                " Highlight current line
set showmatch                 " Show matching brackets
set hlsearch                  " Highlight search results
set incsearch                 " Incremental search
set ignorecase                " Case insensitive search
set smartcase                 " Smart case search
set autoindent                " Auto indent
set smartindent               " Smart indent
set expandtab                 " Use spaces instead of tabs
set tabstop=4                 " Tab width
set shiftwidth=4              " Indent width
set softtabstop=4             " Soft tab width
set wrap                      " Wrap lines
set linebreak                 " Break lines at word boundaries
set scrolloff=8               " Keep 8 lines above/below cursor
set sidescrolloff=8           " Keep 8 columns left/right of cursor
set mouse=a                   " Enable mouse support
set clipboard=unnamedplus     " Use system clipboard
set hidden                    " Allow hidden buffers
set updatetime=300            " Faster completion
set timeoutlen=500            " Faster key sequence completion
set cmdheight=2               " More space for displaying messages
set shortmess+=c              " Don't pass messages to completion menu

" ============================================================================
" Visual Settings
" ============================================================================
syntax enable                 " Enable syntax highlighting
set background=dark           " Dark background
colorscheme default           " Default color scheme (will be enhanced with plugins)
set termguicolors             " Enable true colors
set signcolumn=yes            " Always show sign column
set colorcolumn=80,120        " Show column guides at 80 and 120 characters

" ============================================================================
" File Settings
" ============================================================================
set backup                    " Enable backups
set backupdir=~/.vim/backup// " Backup directory
set directory=~/.vim/swap//   " Swap file directory
set undofile                  " Enable persistent undo
set undodir=~/.vim/undo//     " Undo directory

" Create directories if they don't exist
if !isdirectory($HOME."/.vim/backup")
    call mkdir($HOME."/.vim/backup", "p")
endif
if !isdirectory($HOME."/.vim/swap")
    call mkdir($HOME."/.vim/swap", "p")
endif
if !isdirectory($HOME."/.vim/undo")
    call mkdir($HOME."/.vim/undo", "p")
endif

" ============================================================================
" Plugins (using vim-plug)
" ============================================================================
call plug#begin('~/.vim/plugged')

" Essential plugins for development
Plug 'tpope/vim-sensible'           " Sensible defaults
Plug 'tpope/vim-fugitive'           " Git integration
Plug 'tpope/vim-surround'           " Surround text objects
Plug 'tpope/vim-commentary'         " Easy commenting
Plug 'tpope/vim-repeat'             " Repeat plugin commands
Plug 'tpope/vim-unimpaired'         " Useful bracket mappings

" File and navigation
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'             " Fuzzy finder
Plug 'preservim/nerdtree'           " File explorer
Plug 'Xuyuanp/nerdtree-git-plugin' " Git status in NerdTree

" Language support
Plug 'sheerun/vim-polyglot'         " Language pack
Plug 'dense-analysis/ale'           " Linting and fixing
Plug 'neoclide/coc.nvim', {'branch': 'release'} " Code completion

" Visual enhancements
Plug 'vim-airline/vim-airline'      " Status line
Plug 'vim-airline/vim-airline-themes'
Plug 'morhetz/gruvbox'              " Color scheme
Plug 'airblade/vim-gitgutter'       " Git diff in gutter

" Development tools
Plug 'editorconfig/editorconfig-vim' " EditorConfig support
Plug 'jiangmiao/auto-pairs'         " Auto close brackets
Plug 'mattn/emmet-vim'              " HTML/CSS shortcuts

call plug#end()

" ============================================================================
" Plugin Configuration
" ============================================================================

" Gruvbox color scheme
try
    colorscheme gruvbox
catch
    " Fallback to default if gruvbox not available
    colorscheme default
endtry

" Airline configuration
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline_powerline_fonts = 1

" NerdTree configuration
let g:NERDTreeWinPos = "left"
let g:NERDTreeWinSize = 30
let g:NERDTreeShowHidden = 1
let g:NERDTreeIgnore = ['\.pyc$', '\.pyo$', '\.git$', '\.hg$', '\.svn$', '\.bzr$', 'node_modules', '__pycache__']

" ALE configuration (linting)
let g:ale_linters = {
\   'javascript': ['eslint'],
\   'python': ['flake8', 'pylint'],
\   'typescript': ['tslint', 'tsserver'],
\   'json': ['jsonlint'],
\   'yaml': ['yamllint'],
\}
let g:ale_fixers = {
\   'javascript': ['prettier', 'eslint'],
\   'python': ['autopep8', 'black'],
\   'typescript': ['prettier', 'tslint'],
\   'json': ['prettier'],
\   'yaml': ['prettier'],
\   'css': ['prettier'],
\   'html': ['prettier'],
\}
let g:ale_fix_on_save = 1
let g:ale_sign_column_always = 1

" FZF configuration
let g:fzf_layout = { 'down': '40%' }

" ============================================================================
" Key Mappings
" ============================================================================

" Set leader key
let mapleader = " "

" General mappings
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :x<CR>
nnoremap <leader>Q :q!<CR>

" File operations
nnoremap <leader>e :NERDTreeToggle<CR>
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>r :Rg<CR>

" Git operations
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>gc :Git commit<CR>
nnoremap <leader>gp :Git push<CR>
nnoremap <leader>gl :Git pull<CR>

" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Buffer navigation
nnoremap <leader>n :bnext<CR>
nnoremap <leader>p :bprev<CR>
nnoremap <leader>d :bdelete<CR>

" Clear search highlighting
nnoremap <leader>/ :nohlsearch<CR>

" Quick edit vimrc
nnoremap <leader>ev :edit $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>

" Toggle line numbers
nnoremap <leader>ln :set number! relativenumber!<CR>

" ============================================================================
" Language-specific settings
" ============================================================================

" JavaScript/TypeScript
autocmd FileType javascript,typescript setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType json setlocal shiftwidth=2 tabstop=2 softtabstop=2

" Python
autocmd FileType python setlocal shiftwidth=4 tabstop=4 softtabstop=4
autocmd FileType python setlocal colorcolumn=79

" HTML/CSS
autocmd FileType html,css,scss setlocal shiftwidth=2 tabstop=2 softtabstop=2

" YAML
autocmd FileType yaml setlocal shiftwidth=2 tabstop=2 softtabstop=2

" Markdown
autocmd FileType markdown setlocal wrap linebreak

" ============================================================================
" Development helpers
" ============================================================================

" Automatically install plugins on first run
if empty(glob('~/.vim/plugged'))
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Show current Git branch in status line
function! GitBranch()
  return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

" Highlight trailing whitespace
highlight TrailingWhitespace ctermbg=red guibg=red
match TrailingWhitespace /\s\+$/

" Remove trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" Return to last edit position when opening files
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif
EOF

# Set proper ownership
chown -R "$VSCODE_USER:$VSCODE_USER" "/home/$VSCODE_USER/.vim"
chown "$VSCODE_USER:$VSCODE_USER" "$VIMRC_FILE"

log_success "Vim configuration completed!"
echo ""
echo "🔧 Vim Features Configured:"
echo "  ✅ Modern Vim configuration with sensible defaults"
echo "  ✅ Plugin manager (vim-plug) installed"
echo "  ✅ Essential development plugins configured"
echo "  ✅ Language-specific settings (JS, Python, .NET)"
echo "  ✅ Git integration with fugitive"
echo "  ✅ File explorer (NerdTree)"
echo "  ✅ Fuzzy finder (FZF)"
echo "  ✅ Code completion and linting (CoC + ALE)"
echo "  ✅ Modern color scheme (Gruvbox)"
echo ""
echo "💡 Vim Quick Reference:"
echo "  • Space + e      - Toggle file explorer"
echo "  • Space + f      - Find files"
echo "  • Space + r      - Search in files"
echo "  • Space + gs     - Git status"
echo "  • Space + w      - Save file"
echo "  • Space + q      - Quit"
echo ""
echo "📚 First time setup:"
echo "  1. Open vim"
echo "  2. Run :PlugInstall to install plugins"
echo "  3. Restart vim to activate all features"
echo ""
