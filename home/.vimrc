" Small, plugin-free Vim configuration suitable for remote and local work.
set nocompatible
syntax enable
filetype plugin indent on

set encoding=utf-8
set number
set cursorline
set showcmd
set showmatch
set laststatus=2
set wildmenu

set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set autoindent
set smartindent

set ignorecase
set smartcase
set incsearch
set hlsearch

set backspace=indent,eol,start
set splitbelow
set splitright
set scrolloff=3
set sidescrolloff=5

" Keep recovery and undo files out of project directories.
let s:vim_cache = expand('$HOME/.cache/vim')
call mkdir(s:vim_cache . '/backup', 'p')
call mkdir(s:vim_cache . '/swap', 'p')
set backup
execute 'set backupdir=' . s:vim_cache . '/backup//'
execute 'set directory=' . s:vim_cache . '/swap//'
if has('persistent_undo')
  call mkdir(s:vim_cache . '/undo', 'p')
  set undofile
  execute 'set undodir=' . s:vim_cache . '/undo//'
endif

" Makefiles require literal tab characters; Python conventionally uses 4 spaces.
autocmd FileType make setlocal noexpandtab
autocmd FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4
