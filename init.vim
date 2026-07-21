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

" Use the Vim9 LSP client for semantic C# navigation. Keep its completion,
" diagnostics, and highlighting disabled because ALE already owns that UI.
if isdirectory(expand('~/.vim/pack/dotfiles/start/lsp'))
  " GUI launchers do not necessarily inherit the interactive shell's
  " DOTNET_ROOT.  Global-tool apphosts such as csharp-ls need it when .NET is
  " installed outside the platform default (for example, /opt/dotnet).
  if empty($DOTNET_ROOT)
    let s:dotnet_executable = exepath('dotnet')
    if !empty(s:dotnet_executable)
      let $DOTNET_ROOT = fnamemodify(resolve(s:dotnet_executable), ':h')
    endif
  endif

  let g:lsp_options = {
        \ 'autoComplete': v:false,
        \ 'autoHighlightDiags': v:false,
        \ 'highlightDiagInline': v:false,
        \ 'semanticHighlight': v:false,
        \ 'showDiagInBalloon': v:false,
        \ 'showDiagInPopup': v:false,
        \ 'showDiagWithSign': v:false,
        \ 'showSignature': v:false,
        \}

  function! s:SetUpCSharpLspMappings() abort
    if &filetype !=# 'cs'
      return
    endif

    nnoremap <silent> <buffer> <C-]> :<C-u>call <SID>CSharpNavigate(0)<CR>
    nnoremap <silent> <buffer> <C-S-]> :<C-u>call <SID>CSharpNavigate(1)<CR>
    nnoremap <silent> <buffer> g<C-]> :<C-u>call <SID>CSharpNavigate(1)<CR>
  endfunction

  function! s:FinishQueuedCSharpNavigation(request, timer) abort
    if !bufexists(a:request.buffer)
          \ || win_id2win(a:request.window) == 0
          \ || win_getid() != a:request.window
          \ || bufnr() != a:request.buffer
      call timer_stop(a:timer)
      return
    endif

    if LspServerReady()
      call timer_stop(a:timer)
      call cursor(a:request.line, a:request.column)
      execute (a:request.open_in_tab
            \ ? 'tab LspGotoDefinition'
            \ : 'LspGotoDefinition')
      return
    endif

    let a:request.attempts += 1
    if a:request.attempts >= 200
      call timer_stop(a:timer)
      echoerr 'C# language server did not become ready; use :LspServer show status'
    endif
  endfunction

  function! s:CSharpNavigate(open_in_tab) abort
    if LspServerReady()
      execute (a:open_in_tab
            \ ? 'tab LspGotoDefinition'
            \ : 'LspGotoDefinition')
      return
    endif

    echo 'C# language server is starting; definition request queued'
    let request = {
          \ 'attempts': 0,
          \ 'buffer': bufnr(),
          \ 'column': col('.'),
          \ 'line': line('.'),
          \ 'open_in_tab': a:open_in_tab,
          \ 'window': win_getid(),
          \}
    call timer_start(100,
          \ function('<SID>FinishQueuedCSharpNavigation', [request]),
          \ {'repeat': 200})
  endfunction

  augroup dotfiles_csharp_lsp
    autocmd!
    autocmd User LspSetup call LspAddServer([{
          \ 'name': 'csharp-ls',
          \ 'filetype': 'cs',
          \ 'path': expand('~/.dotnet/tools/csharp-ls'),
          \ 'args': [],
          \ 'rootSearch': ['.git/'],
          \ 'syncInit': v:true,
          \}])
    autocmd FileType cs call <SID>SetUpCSharpLspMappings()
    " Apply again after loadview restores any obsolete buffer-local mappings.
    autocmd BufWinEnter *.cs call <SID>SetUpCSharpLspMappings()
    autocmd User LspAttached call <SID>SetUpCSharpLspMappings()
  augroup END
endif

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

  function! s:VimspectorBalanceSidebar() abort
    if !empty(s:vimspector_zoom_restore)
          \ || !exists('g:vimspector_session_windows')
      return
    endif

    let windows = g:vimspector_session_windows
    let pane_names = ['variables', 'watches', 'stack_trace']
    for name in pane_names
      if !has_key(windows, name) || !win_id2win(windows[name])
        return
      endif
    endfor

    if get(windows, 'mode', '') ==# 'horizontal'
      let total_height = 0
      for name in pane_names
        let total_height += winheight(win_id2win(windows[name]))
        call win_execute(windows[name], 'setlocal nowinfixheight')
      endfor

      " Variables and Watches get exactly the same height. StackTrace uses
      " the remaining third (including any rounding row).
      let value_height = max([3, total_height / 3])
      let stack_height = max([3, total_height - (2 * value_height)])
      call win_execute(windows.stack_trace, 'resize ' . stack_height)
      call win_execute(windows.watches, 'resize ' . value_height)
      call win_execute(windows.variables, 'resize ' . value_height)
      call win_execute(windows.variables, 'setlocal winfixheight')
      call win_execute(windows.watches, 'setlocal winfixheight')
    else
      let total_width = 0
      for name in pane_names
        let total_width += winwidth(win_id2win(windows[name]))
        call win_execute(windows[name], 'setlocal nowinfixwidth')
      endfor

      let value_width = max([12, total_width / 3])
      let stack_width = max([12, total_width - (2 * value_width)])
      call win_execute(windows.stack_trace, 'vertical resize ' . stack_width)
      call win_execute(windows.watches, 'vertical resize ' . value_width)
      call win_execute(windows.variables, 'vertical resize ' . value_width)
      call win_execute(windows.variables, 'setlocal winfixwidth')
      call win_execute(windows.watches, 'setlocal winfixwidth')
    endif
  endfunction

  command! VimspectorBalanceSidebar call <SID>VimspectorBalanceSidebar()

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

    " Some terminals do not pass the Delete key through consistently. Make
    " dd remove the stored watch instead of merely deleting its rendered line.
    if has_key(windows, 'watches') && win_id2win(windows.watches)
      call win_execute(windows.watches,
            \ 'nnoremap <silent> <buffer> dd :<C-u>call vimspector#DeleteWatch()<CR>')
    endif

    call s:VimspectorBalanceSidebar()

    call win_gotoid(original_window)
  endfunction

  function! s:VimspectorResetUIState() abort
    let s:vimspector_zoom_restore = ''
  endfunction

  augroup dotfiles_vimspector_ui
    autocmd!
    autocmd User VimspectorUICreated call <SID>VimspectorSetUpUI()
    autocmd User VimspectorJumpedToFrame call <SID>VimspectorBalanceSidebar()
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
