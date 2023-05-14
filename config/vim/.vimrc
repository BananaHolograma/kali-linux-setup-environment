let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim' 

if empty(glob(data_dir . '/autoload/plug.vim'))
      silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugins')

Plug 'davidhalter/jedi-vim'
Plug 'lifepillar/vim-mucomplete'
Plug 'sheerun/vim-polyglot'
Plug 'LunarWatcher/auto-pairs'
Plug 'tpope/vim-sensible'
Plug 'tmsvg/pear-tree'
Plug 'fatih/vim-go'
Plug 'scrooloose/syntastic'
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'

call plug#end()

let mapleader=','

nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

" Move between NerdTree splits
nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>

hi Normal ctermbg=NONE
hi NonText ctermbg=NONE
hi SignColumn ctermbg=NONE
hi LineNr ctermbg=NONE
hi VertSplit ctermbg=NONE
hi Folded ctermbg=NONE
hi Visual cterm=NONE ctermbg=0 ctermfg=NONE guibg=Grey40

if exists("&smoothscroll")
    set smoothscroll
endif

if $COLORSCHEME == 'gnome-terminal'
    set t_Co=256
endif

set complete-=preview
set completeopt+=menuone,noselect
set shortmess+=c

set nocompatible

set tabpagemax=10
set history=500
set ruler
set cmdheight=2
set hid

set complete-=t
set complete-=i

if has('mouse_xterm')
    set mouse=a
endif

set number

set ignorecase
set smartcase
set hlsearch
set incsearch
set lazyredraw
set magic
set showmatch
set autoindent
set nosmartindent
set copyindent
set preserveindent

if exists("&belloff")
    set belloff=all
endif

set noerrorbells
set novisualbell
set t_vb=
set tm=500

syntax enable
filetype off 
set regexpengine=0

set encoding=UTF-8
set ffs=unix,dos,mac

set nobackup
set nowb
set noswapfile

set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set softtabstop=4

set wildmenu                    " nice tab-completion on the command line
set wildmode=longest,full       " nicer tab-completion on the command line
set hidden                      " side effect: undo list is not lost on C-^
set browsedir=buffer            " :browse e starts in %:h, not in $PWD
set autoread                    " automatically reload files changed on disk
set switchbuf=useopen           " quickfix reuses open windows
set iskeyword-=/                " Ctrl-W in command-line stops at /
set splitright                  " put new splits on the right please

let g:pear_tree_smart_closers = 1
let g:NERDTreeWinPos = "right"
let g:mucomplete#enable_auto_at_startup = 1
let g:jedi#popup_on_dot = 0
