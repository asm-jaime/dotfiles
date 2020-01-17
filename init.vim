filetype plugin on

" ==================== vundle init
set rtp+=~/dotfiles/bundle/Vundle.vim
call vundle#begin("~/dotfiles/bundle")
Plugin 'gmarik/Vundle.vim'
Plugin 'fatih/vim-go'
Plugin 'w0rp/ale'
Plugin 'zxqfl/tabnine-vim'
call vundle#end()

" ========== syntax
syntax off  " disable any light syntax

" ========== colorscheme
" colorscheme darkness

set background=dark

hi clear
hi LineNr       ctermfg=white ctermbg=black

hi StatusLine   ctermfg=black ctermbg=white
hi StatusLineNC ctermfg=black ctermbg=white

" === complete menu
" hi Pmenu           ctermfg=white ctermbg=black
" hi PmenuSel        ctermfg=black ctermbg=white
" hi PmenuSbar       ctermbg=white
" hi PmenuThumb      ctermfg=black

" ========== leader
"let mapleader = ","
"let g:mapleader = ","

" ========== set working directory to the current file
set autochdir

" ========== newline setting
set textwidth=0 wrapmargin=0    " prevent from autoinsert line breaks in new text

" ========== window setting
set number
set lines=45
set columns=90

" ==================== tab of editor
set smarttab                    " tabs as shiftwidth
set nolist                      " hide whitespace and of lines symbols like '$'
set expandtab                   " insert spaces when TAB is pressed
set tabstop=2                   " set n whitespase as tabs
set shiftwidth=2                " set n whitespace when pressed >> and <<.
set autoindent                  " autotabs for new line
set nostartofline               " not change cursor when change positiona in buffer
set cindent                     " enable indents with C style

" ========== save view state
autocmd BufWinLeave * silent! mkview    " save view (state) (folds, cursor, etc)
autocmd BufWinEnter * silent! loadview  " load view (state)

" ===================== copy-paste/clipboard/yank
vmap <leader>y y:new ~/.vbuf<CR>VGp:x<CR> " copy to file
nmap <leader>p :r ~/.vbuf<CR>             " paste from file

" ==================== history/save
let g:netrw_dirhistmax = 0        " will stop writing to the history file
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
let g:netrw_banner=0    " hide netrw top message
let g:netrw_liststyle=3 " tree listing by default
let g:netrw_chgwin=1    " open files in left window by default
nmap <silent> <leader><leader>f :leftabove 20vs<CR>:e .<CR>

" === ALE, error checker

let g:ale_linters = {'c': ['gcc', 'clangcheck', 'clangtidy', 'cppcheck', 'cpplint', 'cquery', 'flawfinder', 'clang'], 'go': ['gobuild', 'gofmt', 'golint', 'gotype', 'govet', 'golangserver'], 'javascript': ['eslint']}

let g:ale_linters_explicit = 1
let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_enter = 0

let g:ale_set_loclist = 0
"let g:ale_set_quickfix = 1

"let g:ale_open_list = 1
let g:ale_keep_list_window_open = 0

"let g:ale_completion_enabled = 1
"let g:deoplete#sources = {'_': ['ale']}

"let g:ale_completion_delay = 100
"let g:ale_completion_max_suggestions = 50

noremap <Leader>def :ALEGoToDefinitionInTab<CR>
noremap <Leader>ref :ALEFindReferences<CR>

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
" let g:go_fmt_fail_silently = 0

" let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck']

setlocal omnifunc=go#complete#Complete

" === keybinding
" autocmd FileType go nmap <leader>df <Plug>(go-def-tab)
" au BufWritePost *.go :!gofmt -w %

" ==================== c

" ==================== html
 autocmd Filetype html setlocal expandtab
 autocmd Filetype javascript setlocal expandtab
