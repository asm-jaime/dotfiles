filetype plugin on

" ==================== vundle init
set rtp+=~/dotfiles/bundle/Vundle.vim
call vundle#begin("~/dotfiles/bundle")
Plugin 'gmarik/Vundle.vim'
Plugin 'w0rp/ale'
call vundle#end()

" ========== syntax
syntax off  " disable all syntax highlighting

" ========== colorscheme

set background=dark

hi clear
hi LineNr       ctermfg=white ctermbg=black

hi StatusLine   ctermfg=black ctermbg=white
hi StatusLineNC ctermfg=black ctermbg=white

" === complete menu
hi Pmenu           ctermfg=white ctermbg=black
hi PmenuSel        ctermfg=black ctermbg=white
hi PmenuSbar       ctermbg=white
hi PmenuThumb      ctermfg=black

" ========== leader
let mapleader = ","
let g:mapleader = ","

" ========== set the work directory to the file directory
set autochdir

" ========== newline setting
set textwidth=0 wrapmargin=0    " prevent the line break autoinsert to new text

" ========== window setting
set number
" set lines=45
" set columns=90

" ========== terminal
" exit from terminal mode on Esc
tnoremap <Esc> <C-\><C-n>

" ==================== smart whitespaces for the insert mode
set smarttab                    " smart shiftwidth on each new line
set nolist                      " hide the word separators as '$'
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
set paste

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

let g:ale_linters = {'c': ['gcc', 'clangcheck', 'clangtidy', 'cppcheck', 'cpplint', 'cquery', 'flawfinder', 'clang'], 'javascript': ['eslint']}

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

" ==================== tabnine

let g:ycm_autoclose_preview_window_after_completion = 1

" === keybinding
" autocmd FileType go nmap <leader>df <Plug>(go-def-tab)
" au BufWritePost *.go :!gofmt -w %

" ==================== c

" ==================== html
 autocmd Filetype html setlocal expandtab
 autocmd Filetype javascript setlocal expandtab
