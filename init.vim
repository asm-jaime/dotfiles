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

function! s:CSharpMethodName(line_text) abort
  return matchstr(
        \ a:line_text,
        \ '^\s*\%(\%(public\|private\|protected\|internal\|static\|async\|virtual\|override\|sealed\|new\|partial\)\s\+\)*\S\+\s\+\zs\h\w*\ze\s*('
        \ )
endfunction

function! s:DebugNUnitTestUnderCursor() abort
  if &filetype !=# 'cs'
    echoerr 'F2 NUnit debugging is available only in C# files'
    return
  endif

  let attribute_line = searchpos('^\s*\[Test\]\s*$', 'bcnW')[0]
  if attribute_line == 0
    echoerr 'No [Test] method found at the cursor'
    return
  endif

  let method_line = 0
  let test_name = ''
  for line_number in range(attribute_line + 1, min([line('$'), attribute_line + 20]))
    let candidate = s:CSharpMethodName(getline(line_number))
    if !empty(candidate)
      let method_line = line_number
      let test_name = candidate
      break
    endif
  endfor

  if method_line == 0
    echoerr 'No method declaration found after [Test]'
    return
  endif

  for line_number in range(method_line + 1, line('$'))
    if !empty(s:CSharpMethodName(getline(line_number)))
      if line('.') >= line_number
        echoerr 'Place the cursor on or inside a [Test] method'
        return
      endif
      break
    endif
  endfor

  call vimspector#SetLineBreakpoint(expand('%:p'), method_line)
  echo 'Debugging NUnit test: ' . test_name
  call vimspector#LaunchWithSettings({ 'TestFilter': 'Name=' . test_name })
endfunction

" Vimspector talks to the already-installed NetCoreDbg adapter directly.
" Keeping it under opt means this file also loads cleanly before installation.
if isdirectory(expand('~/.vim/pack/dotfiles/opt/vimspector'))
  let g:vimspector_enable_mappings = 'HUMAN'
  let g:vimspector_sidebar_width = 52
  let g:vimspector_bottombar_height = 8
  let g:vimspector_code_minwidth = 72
  let g:vimspector_topbar_height = 12
  let g:vimspector_code_minheight = 12
  let g:vimspector_adapters = {
        \ 'netcoredbg': {
        \   'name': 'netcoredbg',
        \   'command': [expand('~/.local/bin/netcoredbg'), '--interpreter=vscode'],
        \ },
        \}
  packadd vimspector

  let s:vimspector_zoom_restore = ''

  function! s:VimspectorFocusWindow(name) abort
    let target_window = get(get(g:, 'vimspector_session_windows', {}), a:name, 0)
    if !exists('g:vimspector_session_windows')
          \ || win_id2tabwin(target_window)[0] == 0
      echoerr 'The Vimspector ' . a:name . ' window is not open'
      return
    endif

    if !empty(s:vimspector_zoom_restore)
      execute s:vimspector_zoom_restore
      let s:vimspector_zoom_restore = ''
    endif
    call win_gotoid(target_window)
  endfunction

  function! s:VimspectorToggleZoom() abort
    if !exists('g:vimspector_session_windows')
      echoerr 'No Vimspector session is open'
      return
    endif

    if empty(s:vimspector_zoom_restore)
      let s:vimspector_zoom_restore = winrestcmd()
      wincmd |
      wincmd _
      echo 'Debugger pane expanded; press ,dz to restore the layout'
    else
      execute s:vimspector_zoom_restore
      let s:vimspector_zoom_restore = ''
    endif
  endfunction

  function! s:VimspectorSetUpUI() abort
    let s:vimspector_zoom_restore = ''
    let windows = g:vimspector_session_windows
    let original_window = win_getid()

    for name in ['variables', 'watches', 'stack_trace', 'output']
      if has_key(windows, name) && win_id2win(windows[name])
        call win_execute(windows[name],
              \ 'setlocal nonumber norelativenumber nowrap sidescroll=1 sidescrolloff=3')
      endif
    endfor

    " Enter or Tab expands an object. K shows its complete value and type.
    for name in ['variables', 'watches']
      if has_key(windows, name) && win_id2win(windows[name])
        call win_execute(windows[name],
              \ 'nnoremap <silent> <buffer> <Tab> :<C-u>call vimspector#ExpandVariable()<CR>')
        call win_execute(windows[name],
              \ 'nmap <silent> <buffer> K <Plug>VimspectorBalloonEval')
      endif
    endfor

    " An empty Watches pane should not take the same space as useful locals.
    if get(windows, 'mode', '') ==# 'horizontal'
      if has_key(windows, 'variables') && win_id2win(windows.variables)
        call win_execute(windows.variables, 'resize 999')
      endif
      if has_key(windows, 'watches') && win_id2win(windows.watches)
        call win_execute(windows.watches, 'resize 1')
      endif
      if has_key(windows, 'stack_trace') && win_id2win(windows.stack_trace)
        call win_execute(windows.stack_trace, 'resize 3')
      endif
    else
      if has_key(windows, 'variables') && win_id2win(windows.variables)
        call win_execute(windows.variables, 'vertical resize 999')
      endif
      if has_key(windows, 'watches') && win_id2win(windows.watches)
        call win_execute(windows.watches, 'vertical resize 12')
      endif
      if has_key(windows, 'stack_trace') && win_id2win(windows.stack_trace)
        call win_execute(windows.stack_trace, 'vertical resize 24')
      endif
    endif

    call win_gotoid(original_window)
  endfunction

  function! s:VimspectorResetUIState() abort
    let s:vimspector_zoom_restore = ''
  endfunction

  augroup dotfiles_vimspector_ui
    autocmd!
    autocmd User VimspectorUICreated call <SID>VimspectorSetUpUI()
    autocmd User VimspectorDebugEnded call <SID>VimspectorResetUIState()
  augroup END

  nnoremap <silent> <F2> :call <SID>DebugNUnitTestUnderCursor()<CR>
  nmap <silent> <F7> <Plug>VimspectorStepInto
  nmap <silent> <F8> <Plug>VimspectorStepOver
  nnoremap <silent> <leader>dc :call <SID>VimspectorFocusWindow('code')<CR>
  nnoremap <silent> <leader>dv :call <SID>VimspectorFocusWindow('variables')<CR>
  nnoremap <silent> <leader>dw :call <SID>VimspectorFocusWindow('watches')<CR>
  nnoremap <silent> <leader>ds :call <SID>VimspectorFocusWindow('stack_trace')<CR>
  nnoremap <silent> <leader>do :call <SID>VimspectorFocusWindow('output')<CR>
  nnoremap <silent> <leader>dz :call <SID>VimspectorToggleZoom()<CR>
endif
