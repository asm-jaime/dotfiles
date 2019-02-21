filetype plugin on

" ==================== vundle init
set rtp+=~/dotfiles/bundle/Vundle.vim
call vundle#begin("~/dotfiles/bundle")
Plugin 'gmarik/Vundle.vim'
Plugin 'fatih/vim-go'
Plugin 'w0rp/ale'
Plugin 'Valloric/YouCompleteMe', { 'do': './install.py --gocode-completer --tern-completer --clang-completer' }
call vundle#end()

" ========== syntax
syntax off  " disable any light syntax

" ========== colorscheme
colorscheme darkness
" set lazyredraw

" ========== leader
let mapleader = ","
let g:mapleader = ","

" ========== set working directory to the current file
set autochdir

" ========== newline setting
set textwidth=0 wrapmargin=0    " prevent from autoinsert line breaks in new text

" ========== more natural splits
set splitbelow                  " horizontal split below current
set splitright                  " vertical split to right of current

" ========== window setting
set number
set lines=30
set columns=90

" ==================== tab of editor
set smarttab                    " tabs as shiftwidth
set list                        " show whitespace. end of lines show as '$'
set expandtab                   " insert spaces when TAB is pressed
set tabstop=2                   " set n whitespase as tabs
set shiftwidth=2                " set n whitespace when pressed >> and <<.
set autoindent                  " autotabs for new line
set nostartofline               " not change cursor when change positiona in buffer
set cindent                     " enable indents with C style

" ========== save view state
autocmd BufWinLeave * silent! mkview    " save view (state) (folds, cursor, etc)
autocmd BufWinEnter * silent! loadview  " load view (state)

" ===================== copy-paste
vmap <leader>y y:new ~/.vbuf<CR>VGp:x<CR> " copy to file
nmap <leader>p :r ~/.vbuf<CR>             " paste from file

" ==================== history
let g:netrw_dirhistmax = 0      " netrw will save no history or bookmarks
set history=10000
set undodir=~/dotfiles/undodir/
set undofile
set undolevels=10000
set undoreload=10000

" ==================== backup
" disable save and swap for any temp files like $x.txt.swap
set nobackup
set nowritebackup
set noswapfile

" ==================== cursor
set virtualedit=  " rectangular selections can be made

" ==================== abbreviations
iabbrev #= ==========

" ==================== search
set nohlsearch  " no highlight found
set incsearch   " shows the match while typing
set ignorecase  " search case insensitive
set smartcase   " but not when search pattern contains upper case characters

" ==================== airline
set noshowmode      " hide inative mode indication
set nocursorcolumn  " hide counter colum
set nocursorline    " hide counter cursor

" ==================== netrw
set mouse=a             " enable mouse usage
let g:netrw_banner=0    " hide netrw top message
let g:netrw_liststyle=3 " tree listing by default
let g:netrw_chgwin=1    " open files in left window by default
" netrw on sidebar
nmap <silent> <leader>f :leftabove 20vs<CR>:e .<CR>

" === YouCompleteMe
let g:ycm_min_num_identifier_candidate_chars = 0
let g:ycm_min_num_of_chars_for_completion = 2
let g:ycm_add_preview_to_completeopt = 1
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_auto_trigger = 1

autocmd FileType javascript,go,c,cpp set omnifunc=syntaxcomplete#Complete

" ==================== go
" # for using vim-go, need to append this strings to .zshrc or .bashrc
" ===
" export GOROOT=/usr/local/go
" export GOPATH=$HOME/BUFF/projects/golang
" export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
" export GOBIN=$GOPATH/bin
" ===
" # after that, run the :GoInstall/:GoInstallBinaries

let g:go_autodetect_gopath = 1

let g:go_fmt_autosave = 1
" let g:go_fmt_command = "goimports"
let g:go_fmt_fail_silently = 0

let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck']

" === keybinding
autocmd FileType go nmap <leader>df <Plug>(go-def-tab)
autocmd FileType go nmap <leader>r <Plug>(go-run)
autocmd FileType go nmap <leader>b <Plug>(go-build)
autocmd FileType go nmap <leader>t <Plug>(go-test)
autocmd FileType go nmap <leader>c <Plug>(go-coverage)
autocmd FileType go nmap <leader>dd <Plug>(go-doc)
autocmd FileType go nmap <leader>s <Plug>(go-implements)
autocmd FileType go nmap <leader>i <Plug>(go-info)
autocmd FileType go nmap <leader>e <Plug>(go-rename)
