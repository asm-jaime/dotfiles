" Personal Vim configuration for Ubuntu. This is intentionally Vim-only.
set nocompatible
filetype plugin indent on

" Keep the deliberately quiet, high-contrast terminal appearance.
syntax off
set background=dark
highlight clear
highlight LineNr       ctermfg=white ctermbg=black
highlight StatusLine   ctermfg=black ctermbg=white
highlight StatusLineNC ctermfg=black ctermbg=white
highlight Pmenu        ctermfg=white ctermbg=black
highlight PmenuSel     ctermfg=black ctermbg=white
highlight PmenuSbar    ctermbg=white
highlight PmenuThumb   ctermfg=black

let mapleader = ','

" Files, buffers, and windows.
set autochdir
set number
set hidden
set splitbelow
set splitright
set wildmenu
set textwidth=0
set wrapmargin=0

" Whitespace and indentation.
set smarttab
set nolist
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set nostartofline

augroup dotfiles_indent
  autocmd!
  autocmd FileType c,cpp,cs setlocal cindent
augroup END

" Vim terminal behavior. Escape returns to Normal mode. Ctrl+C is deliberately
" passed to the terminal job, so it still interrupts a running command.
tnoremap <Esc> <C-\><C-n>
tnoremap <C-c> <C-c>

" Desktop-style copy/paste. In terminal mode these keys remain untouched, so
" Ctrl+C interrupts the job and the terminal emulator owns Ctrl+Shift+V.
if has('clipboard')
  set clipboard^=unnamedplus
  xnoremap <C-c> "+y
  nnoremap <C-S-v> "+p
  inoremap <C-S-v> <C-r>+
  cnoremap <C-S-v> <C-r>+
  xnoremap <C-S-v> "+p
else
  xnoremap <C-c> y
  nnoremap <C-S-v> p
  inoremap <C-S-v> <C-r>"
  cnoremap <C-S-v> <C-r>"
  xnoremap <C-S-v> p
endif

" Persistent undo and view state.
set history=10000
set undofile
set undodir=~/.vim/undo//
set undolevels=10000
set undoreload=10000
set viewdir=~/.vim/view//

augroup dotfiles_views
  autocmd!
  autocmd BufWinLeave ?* if &buftype ==# '' | silent! mkview | endif
  autocmd BufWinEnter ?* if &buftype ==# '' | silent! loadview | endif
augroup END

" Temporary files should not appear beside source files.
set nobackup
set nowritebackup
set noswapfile

" Search and completion UI.
set nohlsearch
set incsearch
set ignorecase
set smartcase
set completeopt=menuone,noinsert,noselect

" Cursor and status display.
set virtualedit=
set noshowmode
set nocursorcolumn
set nocursorline

" Small editing shortcuts retained from the old configuration.
iabbrev #= ==========
vnoremap <leader>y y:new ~/.vbuf<CR>VGp:x<CR>
nnoremap <leader>p :read ~/.vbuf<CR>

" netrw file browser.
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_chgwin = 1
let g:netrw_dirhistmax = 0
nnoremap <silent> <leader><leader>f :leftabove 20vsplit<CR>:edit .<CR>

" ALE runs linters and fixers. Missing executables are skipped, so each
" language stays optional.
let g:ale_linters = {
      \ 'c': ['clangtidy', 'cppcheck'],
      \ 'cpp': ['clangtidy', 'cppcheck'],
      \ 'cs': ['csc'],
      \ 'python': ['pylint'],
      \ 'sh': ['shellcheck'],
      \}
let g:ale_linters_explicit = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_enter = 0
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 0
let g:ale_keep_list_window_open = 0

nnoremap <silent> <leader>an <Plug>(ale_next_wrap)
nnoremap <silent> <leader>ap <Plug>(ale_previous_wrap)
nnoremap <silent> <leader>ad :ALEDetail<CR>

" Vimspector talks to the already-installed NetCoreDbg adapter directly.
" Keeping it under opt means this file also loads cleanly before installation.
if isdirectory(expand('~/.vim/pack/dotfiles/opt/vimspector'))
  let g:vimspector_enable_mappings = 'HUMAN'
  let g:vimspector_adapters = {
        \ 'netcoredbg': {
        \   'name': 'netcoredbg',
        \   'command': [expand('~/.local/bin/netcoredbg'), '--interpreter=vscode'],
        \ },
        \}
  packadd! vimspector
endif
