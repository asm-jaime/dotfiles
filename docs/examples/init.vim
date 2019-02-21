"==================== start faq

" ==================== introduction {{{
"
" === installation neovim
" sudo add-apt-repository ppa:neovim-ppa/unstable
" sudo apt-get update
" sudo apt-get install neovim
"
" ===
" the vim have 4 modes:
" normal (all navigation/transform/folding/etc commands, to press: 'esc')
" visual (select any text for transformation, to press: 'v','shift-v',..)
" insert (write any text, to press: 'i','a',..)
" last line (write text command, to press: ':', quit is ':q', write and quit is ':wq')
" addition mode:
" control wnd (split/nav/q/.. buff, to press: 'ctrl+w'
"   example: shift cursor to the left 'wtrl+w h')
"
" ==================== introduction }}}

" ==================== console {{{
"
" ==== package manager
" apt-get install name              # install some package from internet
" apt-get purge name                # remove only this package
" apt-get purge --auto-remove name  # remove along with dependencies
"
" === environment
" printenv                    # show env vars
" export SOME_VAR=some_value  # set env var
" unset SOME_VAR              # erase the existence of an env var
" sudo nvim /etc/environment  # set permanent env vars
"
" === task manager/monitor/gnome-system-monitor
" gnome-system-monitor
" top
"
" === disk (/dev/sd*, /etc/fstab)
" df -T                   # show disk info
" blkid                   # show uuid disk
" mount -all              # mount all disk emumed in /etc/fstab
"
" === process
" killall -v nameprocess  # kill a process
" sudo lsof -i :3476      # show name process what use port
"
" === find/grep/etc (file operations)
" find . -name *.cpp | xargs sed -i 's/pat/rep/'  # replace in all files
" grep -rnw '/path/' -e "what_search"             # search word in all files
" grep --include=\*.{c,h} -rnw '/path/' -e "pat"  # include some files for search
" grep --exclude-dir={dir1,dir2,*.dst} ...        # exlude array of dir
"
" grep -Ril "text-to-find-here" / # {i-ignore case, l-show the file, /-at the root}
"
" === compile files
" for D in *; do {echo '/*'; cat "$D/$D".ini; echo '*/'; cat "$D/$D".c;}
" >> "$D/$D".cc; done
"
" === jobs in console
" ctrl+z            # stopped job
" fg                # resume job
"
" === change premissionr
" r read the file or dir
" w	write to the file or dir
" x	execute the file or search the dir
"
" ===
" chmod 0755 -R /*    # 755 = -rwxr-xr-x
" chmod u+x file.sh   # permissions to make it executable for yourself
"
" === display
" xrandr -s 1280x960  #  changing screen-resolution
"
" ==================== console }}}

" ==================== tmux section {{{
"
" === intro
" prefix - ctrl+b as default, begin to command mode tmux
"
" === tmux ssh/etc connection
" ssh -p 2222 user@your-ip  # standart command for connection
"
" === restore all sessions
" tmux new-session -d -s 0 '~/.tmux/plugins/tmux-resurrect/scripts/restore.sh'
"
" === attach/kill/etc session
" tmux ls                   # show all sessions
" tmux new -s myname        # start new with session name
" tmux a -t myname          # attach to named
" tmux kill-session -t name # kill session
" ctrl + d                  # kill this window
" prefix + c                # add new window
" prefix + <window num>     # switch between windows 0 and 1
" prefix + %                # vertical split
" prefix + "                # horizontal split
" prefix + z                # into full-screen
"
" === Windows (tabs)
" :new<CR>          # new session
" s                 # list sessions
" $                 # name session
"
" c                 # new window
" ,                 # name window
" w                 # list windows
"
" n                 # next window
" p                 # previous window
"
" f                 # find window
" &                 # kill window
" .                 # move window - prompted for a new number
" :movew<CR>        # move window to the next unused number
"
" === Panes (splits)
" %                 # horizontal split
" "                 # vertical split
"
" o                 # swap panes
" q                 # show pane numbers
" x                 # kill pane
" ⍽                 # space - toggle between layouts
"
" === Window/pane surgery
" :joinp -s :2<CR>  # move window 2 into a new pane in the current window
" :joinp -t :1<CR>  # move the current pane into a new pane in window 1
"
" === Reorder windows
" d                 # detach
" t                 # big clock
" ?                 # list shortcuts
" :                 # prompt
"
" === vi function (to enter ctrl-b+[)
" ^            # Back to indentation
" Escape       # Clear selection
" Enter        # Copy selection
" j            # Cursor down
" h            # Cursor left
" l            # Cursor right
" L            # Cursor to bottom line
" M            # Cursor to middle line
" H            # Cursor to top line
" k            # Cursor up
" d            # Delete entire line
" D            # Delete to end of line
" $            # End of line
" :            # Goto line
" C-d          # Half page down
" C-f          # Half page up
" C-u          # Next page
" w            # Next word
" p            # Paste buffer
" C-b          # Previous page
" C-Down or J  # Scroll down
" C-Up or K    # Scroll up
" b            # Previous word
" q            # Quit mode
" n            # Search again
" ?            # Search backward
" /            # Search forward
" 0            # Start of line
" Space        # Start selection
" C-t          # Transpose char
"
" === command
" :source-file ~/.tmux.conf # reload config file
"
" ==================== }}}

" ==================== git {{{
"
" === info project
"
" git ls-files | xargs wc -l    # show number of lines in a git repository
"
" === info commits
" git log                                     # show short 2st log commits
" git log --graph --oneline --decorate --all  # show full log commits
" git log -p -2                               # show full info about commts
" git log --stat
" git shortlog
" git show
" git status                                  # show status local repos
" git describe
"
" === show commits as graph (one line command)
" git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset)
" - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)
" - %an%C(reset)%C(bold yellow)%d%C(reset)' --all
"
" === info diff
" git difftool
" git diff --staged
" git diff master branchB
"
" === operation add
" git add .                     # add changes for local repos
" git add main.c
"
" === operation commit
" git commit -a
" git commit -a -m 'some note'
" git commit -m 'explanation'   # commit changes for local repos
"
" === operation squash+rebase
" git rebase -i HEAD~3          # open dialog for joing commits (replace pick to squash, except 1st)
"
" === operation rebase branch
" git checkout feature1         # need to be on working branch
" git rebase master             # rebase it to master
" git checkout master
" git merge feature1            # do a fast-forward merge
"
" === operation remote
" git remote -v                   # show status remote
" git remote set-url origin       # set retome to origin/github/gitlab/etc..
" git remote set-url origin git@github.com:user/repos.git
" git remote set-url origin https://github.com:user/repos.git
"
" === operation branch
" git branch
" git branch -u
" git branch -v # show status current branch
"
" git branch -d local_branch
" git push origin :remote_branch
"
" git checkout master
" git checkout somebranch
" git checkout -b somebranch
" git checkout somebranch --track
"
" === operation clone
" git clone git@gitlab.com:user/some.git
" git clone git@github.com:user/some.git
"
" === operation pull
" git pull origin
" git pull --recurse-submodules # pull all submodules
"
" === operation push
" git push                      # push changes on remote (default github.com) repo
" git fetch
" git push origin HEAD:patch-1  # push to patch
"
" === operation remove
" git rm
" git rm --cached
" git mv
"
" === operation reset
" git reset
" git reset foo.c                             # undo foo.c file
" git reset --hard
" git hard --reset                            # undo one commit
"
" === operation merge
" git merge somebranch
" git merge somebranch --abort
"
" git clean
" git stash
" git tag
" git archive
"
" === oreration submodules
" git submodule
" git submodule add https://github.com/some.git
" git submodule update --recursive
"
" ==================== git }}}

" ==================== mongodb {{{
" db.coll.find().limit(1).sort({$natural:-1}).pretty()._id  # lastest elem
" db.coll.find({"id": { "$lt" : ObjectId("")}}).count()     # position elem
" ==================== mongodb }}}

" ==================== cgdb {{{
"
" === code buffer
" i               # puts to gdb buffer
" I               # puts the user into TTY mode
" t               # sets a temporary breakpoint at the current line number
" F5              # send a run command to gdb
" F6              # send a continue command to gdb
" F7              # send a finish command to gdb
" F8              # send a next command to gdb
" F10             # send a step command to gdb
" spacebar        # sets a breakpoint at the current line number
"
" === gdb buffer
" alt+n           # switch to code buffer
"
" === all
" ctrl+c          # end run
"
" === gdb
" # compiling with flag -g (gcc -g main.c) required
"
" help            # 'h breakpoints' lists help topics
"
"
" === breakpoints
" break N         # 'b main/N/fn' puts bp at the n line
" delete N        # del bp at the n line, 'd' short
" clear           # 'clear function/N' delete all breakpoints in param
"
" === program
" run             # runs the program until a breakpoint or error
" continue        # 'cont' run the program until the next bp or error
"
" step N          # 's N' runs the next line of the program
" next            # 'n' like 's', but it does not step into functions
" finish          # finishes executing the current function, then pause
"
" function        # 'f' until the current function is finished
" call myfunc()   # calls user-defined or system functions
"
" u N             # runs until you get N lines in front
" u               # goes up a level in the stack
" d               # goes down a level in the stack
"
" quit            # 'q' quits gdb
" kill            # stop program exec

" === info
" info break      # 'info watchpoints/threads/set' list info about
" list myfunc     # 'l N/func/start#/filename:func' 10 lines of source code
"
" === print
" print x         # 'p x' prints the current value of the variable
"
" p *array-variable@length
" p file-name::variable-name
" x/b &var        # print as integer value in binary, p/t/x/c/d/u/o alse, 1 by/8bi
"
" set x = 3       # set x to 3
" watch x == 3    # sets a watch, which pauses the program when a condition changes
"
" display x       # constantly displays the value of variable x
" undisplay x     # removes the constant display of a variable
"
"
" === context
" backtrace full  # 'bt' backtraces prints a stack trace
" frame 1         # 'f number/ ' select/show frame where you alloc
" up              # move to the next frame up in the function stack
" down            # move to the next frame down in the function stack
"
" handle [signalname] [action]  # instruct gdb to react a certain signal
"
"
" ==================== cgdb }}}

" ==================== sessions {{{
"
" :mksession ~/.vim/sessions/session.vim    # make a session
" :source ~/.vim/sessions/session.vim       # restore the session
" vim -S ~/session.vim                      # restore the session from console
"
" ==================== sessions }}}

" ==================== command mode {{{
"
" q:    # show command history
"
" ==================== command mode }}}

" ==================== navigation {{{
"
" === move
" h                 # move one character left
" j                 # move one row down
" k                 # move one row up
" l                 # move one character right
" w                 # move to beginning of next word
" b                 # move to previous beginning of word
" e                 # move to end of word
" W                 # move to beginning of next word after a whitespace
" B                 # move to beginning of previous word before a whitespace
" E                 # move to end of word before a whitespace
"
" === move within the line
" 0                 # move to beginning of line
" $                 # move to end of line
" ^                 # move to first non-blank character in line
" _                 # move to first non-blank character of the line
" g_                # move to last non-blank character of the line
"
" === move within buffer
" gg                # move to first line
" G                 # move to last line
" nG                # move to n'th line of file (n is a number; 12G moves to line 12)
" H                 # move to top of screen
" M                 # move to middle of screen
" L                 # move to bottom of screen
"
" === scroll list
" z.                # scroll the line with the cursor to the center of the screen
" zt                # scroll the line with the cursor to the top
" zb                # scroll the line with the cursor to the bottom
"
" === scroll line
" Ctrl-y            # scroll one line up
" Ctrl-e            # scroll one line down
"
" === scroll page
" Ctrl-D            # move half-page down
" Ctrl-U            # move half-page up
" Ctrl-B            # page up
" Ctrl-F            # page down
"
" === move match
" n                 # next matching search pattern
" N                 # previous matching search pattern
" *                 # next whole word under cursor
" #                 # previous whole word under cursor
" g*                # next matching search (not whole word) pattern under cursor
" g#                # previous matching search (not whole word) pattern under cursor
" %                 # jump to matching bracket { } [ ] ( )
"
" === Jumping to characters
" f<character>      # Jump forward and land on <character>
" F<character>      # Jump forward and land right before <character>
" t<character>      # til next <character> (similar to above)
" T<character>      # til previous <character>
"
" ;                 # repeat above, in same direction
" ,                 # repeat above, in reverse direction
"
" shift+{           # to start paragraph
" shift+}           # to end paragraph
"
" ==================== navigation }}}

" ==================== split windows buffers {{{
"
" ctrl-w up arrow   # move cursor up a window
" ctrl-w ctrl-w     # move cursor to another window (cycle)
" Сtrl-w o          # expand window
" Ctrl-w c          # close window
" Ctrl-w s          # horisontal split
" Ctrl-w v          # vertical split
" Ctrl-w ]          # split and move
" Ctrl-w f          # split and open file-path on cursor
" ctrl-w_           # maximize current window
" ctrl-w=           # make all equal size
" 10 ctrl-w+        # increase window horisontal-size by 10 lines
" 10 ctrl-w>        # increase window vertical-size by 10 lines
" ctrl-w ctrl-p     # move cursor prev window
"
" Ctrl-W K          # vertical to horisontal
" Ctrl-W H          # horisontal to vertical
" Ctrl-W r          # swap
"
" :e filename       # edit another file (:e to reload/refresh the current file)
" :split filename   # split window and load another file
"
" :sb[uffer]        # split and edit buffer. Reopen split again clear it
" :vsplit file      # vertical split
" :sview file       # same as split, but readonly
" :hide             # close current window
" :only             # keep only this window open
" :ls               # show current buffers
" :b 2              # open buffer #2
" :bufdo bd         # close all buffers in this window
"
" ==================== split windows buffers }}}

" ==================== tabs {{{
"
" tab ball          # show each buffer in a tab (up to 'tabpagemax' tabs)
" tab help          # open a new help window in its own tab page
" tab drop {file}   # open {file} in a new tab, or jump to a window/tab containing it
" tab split         # copy the current window to a new tab of its own
"
" tabs              # list all tabs including their displayed windows
" tabm 0            # move current tab to first
" tabm              # move current tab to last
" tabm {i}          # move current tab to position i+1
"
" tabn              # go to next tab
" tabp              # go to previous tab
" tabfirst          # go to first tab
" tablast           # go to last tab
" tabnew            # make new tab
"
" gt                # go to next tab
" gT                # go to previous tab
" {i}gt             # go to tab in position i
" Ctrl-PgDn         # go to next tab
" Ctrl-PgUp         # go to previous tab
"
":tabdo %s/foo/bar/g
"
" ==================== tabs }}}

" ==================== cursor {{{
"
" ``                # switch between the last and current position
" ''                # switch between the last string number and current string number
" Ctrl-O            # move back to previous position cursor
" Ctrl-I            # move next to previous position cursor
" g;                # move back previous edit locations
" g,                # move next previous edit locations
"
" ==================== cursor }}}

" ==================== folding {{{
"
" zc                # fold block
" zo                # open block
" zM                # fold all block
" zR                # open all block
" za                # inersion
" zf                # fold selected
" zi                # disable folding
"
" ==================== folding }}}

" ==================== buffers {{{
"
" .:                # the current buffer
" w:                # buffers in other windows
" b:                # other loaded buffers
" u:                # unloaded buffers
" t:                # tags
" i:                # included files
"
" ==================== buffers }}}

" ==================== text transformations {{{
"
" ========== upper/lower case
"
" g~                # toggle case (HellO to hELLo)
" gU                # upper case (HellO to HELLO)
" gu                # lower case (HellO to hello)
" guu               # current line to lower
"
" === retab/text tabs
" :retab
"
" === operation: transform all tabs to 2 whitespace
" :set shiftwidth=2
" :e ++ff=dos       # convert the ^M linebreak
" gg=G
"
" ==================== text transformations }}}

" ==================== vim-regexp [http://vim.wikia.com/wiki/Search_and_replace] {{{
"
" :%s/foo/bar/g         # foo->bar in all the lines.
" :5,12s/foo/bar/g      # foo->bar for all lines from line 5 to line 12
" :'<,'>s/foo/bar/g     # foo->bar for all lines within a visual selection.
" :.,$s/foo/bar/g       # foo->bar for all lines as current line (.) -> last line ($)
" :'a,'bs/foo/bar/g     # foo->bar for all lines from mark a to mark b
" :.,+2s/foo/bar/g      # foo->bar for the current line (.) and the 2 next lines.
" :g/^baz/s/foo/bar/g	  # foo->bar in each line starting with 'baz'.
" :%s/_\(\w\)/\U\1/g    # foo_bar->fooBar, params with replace to uppercase
" :%s/\s\+$//e          # remove unwanted spaces in end of line
" :%s/foo\_.*bar//g     # select from foo to bar throught lines
"
" ==================== vim-regexp }}}

" ==================== macros {{{
"
" :qa   # Start recording a macro named 'a'
" :q    # Stop recording
" :@a   # Play back the macro
"
" ==================== macros }}}

" ==================== CTRL-P {{{
"
" F5      # refresh the match window and purge the cache
"
" ==================== CTRL-P }}}

" ==================== NNERDComment{{{
"
" ,cc     # cc out the current line or selected
" ,cu     # uncomment cc
"
" ,cn     # cc but forces nesting
" ,c<sp>  # toggle the cc state of the selected line(s)
" ,ci     # toggles the cc state of the selected line(s) individually
" ,cm     # only one set of multipart delimiters
" ,cs     # out the selected lines with a pretty block formatted layout
" ,cy     # cc and yanked first
" ,c$     # from the cursor to the end of line
" ,cA     # cc end of line and geos into insert mode between them
"
" ,ca     # switches to the alternative set of cc
" ,cl     # cc except that the delimiters are aligned down the left side
" ,cb     # right side
"
" ==================== NNERDComment}}}

" ====================

" ==================== vundle init {{{
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
" ========== potential useful
"Plugin 'wincent/command-t'
"Plugin 'textmanip.vim'
"Plugin 'fontsize'
"Plugin 'vim-syntastic/syntastic'
"Plugin 'SirVer/ultisnips'
"Plugin 'honza/vim-snippets'
"Plugin 'matze/vim-move'
"Plugin 'tpope/vim-fugitive'
"Plugin 'nsf/gocode', { 'rtp': 'vim',
"'do': '~/BUFF/PROJECTS/golang/src/github.com/nsf/gocode/vim/symlink.sh' }
"
"Plugin 'https://github.com/heavenshell/vim-jsdoc.git'
"Plugin 'SuperTab'
"Plugin 'benmills/vimux'
"Plugin 'flowtype/vim-flow'
"Plugin 'FredKSchott/CoVim'
"Plugin 'Valloric/YouCompleteMe',
"{ 'do': './install.py --gocode-completer --tern-completer --clang-completer' }
"
"Plugin 'rdnetto/YCM-Generator',  { 'branch': 'stable'}
" ========== text transformation
Plugin 'The-NERD-Commenter'
" Plugin 'terryma/vim-multiple-cursors'
Plugin 'tpope/vim-surround'
" ========== information
Plugin 'vim-airline/vim-airline'
" ========== dir navigation
" Plugin 'ctrlpvim/ctrlp.vim'
" ========== you complete me, omnicomplete, etc
Plugin 'floobits/floobits-neovim'
Plugin 'Valloric/YouCompleteMe', { 'do': './install.py --gocode-completer --tern-completer --clang-completer' }
Plugin 'w0rp/ale'
" ========== golang
Plugin 'fatih/vim-go'
Plugin 'garyburd/go-explorer'
"=========== javascript
Plugin 'ternjs/tern_for_vim'
Plugin 'pangloss/vim-javascript'
" Plugin 'mxw/vim-jsx'
" Plugin 'posva/vim-vue'
Plugin 'maksimr/vim-jsbeautify'
Plugin 'othree/javascript-libraries-syntax.vim'
call vundle#end()
"==================== vundle }}}

" ==================== global settings {{{
set nocompatible              " disable vi
" ========== syntax
filetype plugin indent on     " load modules for file of type
syntax enable                 " autolight syntax
syntax sync minlines=256

set synmaxcol=300
" ========== colorscheme
let g:molokai_original = 1
colorscheme molokai
set lazyredraw                " wait to redraw
" ========== leader
let mapleader = ","
let g:mapleader = ","
" ========== save view state
autocmd BufWinLeave * silent! mkview    " save view (state) (folds, cursor, etc)
autocmd BufWinEnter * silent! loadview  " load view (state)
" ========== set working directory to the current file
set autochdir
" ========== newline setting
set textwidth=0 wrapmargin=0        " prevent from automatically inserting line breaks in newly entered text
set wrap                            " newline for long string
set whichwrap+=b,s,<,>,[,],l,h      " next string on edge current string
" ========== scrolling
set scrolloff=0                     " count line below when scroll
" ========== more natural splits

set splitbelow                      " horizontal split below current.
set splitright                      " vertical split to right of current.
" ========== initial window size
" set lines=59
set columns=90
" ========== colons
set number                          " show num each line
" ========== highlight
nnoremap <C-[> :noh<return><esc>
nnoremap <leader><space> :set hlsearch!<cr>
" ========== ctrl+A is select all
noremap <C-A> ggVG
" ==================== global settings }}}

" ==================== ale asyn-lint {{{
let &runtimepath.=',~/.vim/bundle/ale'
" let g:ale_linters = {
" \   'javascript': ['eslint'],
" \}
" ==================== ale asyn-lint }}}

" ==================== folding {{{
set foldenable              " enable rolding for structure file
"set foldmethod=syntax      " syntax folding
"set foldmethod=indent      " indent folding
set foldmethod=manual       " enable zf for folding a selected block
set foldmethod=marker       " enable folding for mark
set foldmarker={{{,}}}      " mark folding
" ==================== folding }}}

" ==================== move lines {{{
" press z+i(disable folding), if you want move a line through folding
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv
" === backspace
set backspace=indent,eol,start  " powerful backspace
" ==================== move lines }}}

" ==================== tab of editor {{{
set smarttab                    " tabs as shiftwidth
set list                        " show whitespace. end of lines show as '$'
set expandtab                   " insert spaces when TAB is pressed
set tabstop=2                   " set n whitespase as tabs
set shiftwidth=2                " set n whitespace when pressed >> and <<.
set autoindent                  " autotabs for new line
set nostartofline               " not change cursor when change positiona in buffer
set cindent                     " enable indents with C style
" autocmd FileType *.c setlocal tabstop=4 shiftwidth=4
" ==================== tabs of editor }}}

" ==================== copy-paste {{{
" copy-paste with system clipboard
" set clipboard=unnamed
" set clipboard=unnamedplus

" function! ClipboardYank()
  " call system('xclip -i -selection clipboard', @@)
" endfunction
" function! ClipboardPaste()
  " let @@ = system('xclip -o -selection clipboard')
" endfunction

" vnoremap <silent> y y:call ClipboardYank()<cr>
" vnoremap <silent> d d:call ClipboardYank()<cr>
" nnoremap <silent> p :call ClipboardPaste()<cr>p

" copy/pastre throught system clipboard
" vnoremap <leader>y "+y
" nnoremap <leader>y "+y
" vnoremap <leader>p "+p
" nnoremap <leader>p "+p

" allow to copy/paste between vim instances

" vmap <Leader>y "+y

" vmap <Leader>d "+d
" nmap <Leader>p "+p
" nmap <Leader>P "+P
" vmap <Leader>p "+p
" vmap <Leader>P "+P

" vnoremap <leader>y :w! ~/.vbuf<cr>
" vmap <leader>y:new ~/.vbuf<CR>VGp:x<CR>

" === goto command
function! WriteSelected()
  let vbuf = expand('~/.vbuf')
  :echo @0
  :call writefile([@0], vbuf)
endfunction

vnoremap <leader> y :call WriteSelected()<cr>
nnoremap <leader>p :r ~/.vbuf<cr>

" ===================== copy-paste }}}

" ==================== history {{{
let g:netrw_dirhistmax = 0      " netrw will save no history or bookmarks
set history=10000
set undodir=~/.vim/undodir/
set undofile
set undolevels=10000
set undoreload=10000
" ==================== history }}}

" ==================== backup  {{{
" disable save and swap for any temp files like $filename.txt.swap etc
set nobackup
set nowritebackup
set noswapfile
" ==================== backup  }}}

" ==================== cursor {{{
set virtualedit=                        " rectangular selections can be made
set showmatch                           " show start/end bracket
let $NVIM_TUI_ENABLE_CURSOR_SHAPE=2     " show cursor in instert mode

" ==================== cursor }}}

" ==================== abbreviations {{{
iabbrev #= ==========
" ==================== abbreviations }}}

" ==================== search {{{
set hlsearch    " highlight found searches
set incsearch   " shows the match while typing
set ignorecase  " search case insensitive...
set smartcase   " ... but not when search pattern contains upper case characters
" ==================== search }}}

" ==================== airline {{{
" set showcmd         " show me what I'm typing
set noshowmode      " hide native mode indication
set nocursorcolumn  " hide counter colum for other plugin
set nocursorline    " hide counter colum for other plugin
" ==================== airline }}}

" ==================== netrw {{{
" enable mouse usage. makes it easier to browse multiple tabs
set mouse=a
" hide netrw top message
let g:netrw_banner=0
" tree listing by default
let g:netrw_liststyle=3
" open files in left window by default
let g:netrw_chgwin=1
" remap shift-enter to fire up the sidebar
nnoremap <silent> <leader><leader>f :leftabove 20vs<CR>:e .<CR>
" ==================== netrw }}}

" ==================== NERDComment {{{
" add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_c = 1
" allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1
" enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1
" ==================== NERDComment }}}

" ==================== complete {{{
set completeopt=menuone,preview,longest
set complete=.,w,b,u,t,i
if has("autocmd") && exists("+omnifunc")
  autocmd Filetype *
          \ if &omnifunc == "" |
          \   setlocal omnifunc=syntaxcomplete#Complete |
          \ endif
endif
" === YouCompleteMe
"map <Leader>y :YcmForceCompileAndDiagnostics<CR>
let g:python_host_prog = '/usr/bin/python'
let g:ycm_path_to_python_interpreter = '/usr/bin/python'
let g:ycm_min_num_identifier_candidate_chars = 0
let g:ycm_min_num_of_chars_for_completion = 2
let g:ycm_add_preview_to_completeopt = 1
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_auto_trigger = 1

autocmd FileType javascript,go,c,cpp set omnifunc=syntaxcomplete#Complete


" == goto command
function! TabAndGoTo()
  :tab split
  :YcmCompleter GoTo
endfunction

autocmd FileType c nnoremap <buffer> <silent> <leader>df :call TabAndGoTo()<cr>
" autocmd FileType c nnoremap <buffer> <silent> <C-]> :YcmCompleter GoTo<cr>
" map <C-]> :YcmCompleter GoToImprecise<cr>
" ==================== complete }}}

" ==================== c {{{
let g:ycm_global_ycm_extra_conf = "~/.vim/conf.plugins/.ycm_с_conf.py"
" === enable doxygen highlighting
" augroup project
    " autocmd!
    " autocmd BufRead,BufNewFile *.h,*.c set filetype=c.doxygen
" augroup END

" === gf command (<C-W><C-F>), to open file in new tab
let &path.="src/include,/usr/include/AL,"

" let c_no_curly_error=1
"au BufNewFile,BufRead,BufEnter *.cpp,*.h,*.hpp set omnifunc=cpp#complete#Complete filetype=cpp
" ==================== c }}}

" ==================== go {{{
" # for using vim-go, need to append this strings to .zshrc or .bashrc
" ===
" export GOPATH=$HOME/BUFF/projects/golang
" export PATH=$PATH:$GOPATH/bin
" export GOBIN=$GOPATH/bin
" ===
" # after that, run the :GoInstall/:GoInstallBinaries

let g:go_autodetect_gopath = 1

let g:go_fmt_autosave = 1
" let g:go_fmt_command = "goimports"
let g:go_fmt_fail_silently = 0

let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
let g:go_highlight_types = 1
let g:go_highlight_structs = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_space_tab_error = 0
let g:go_highlight_array_whitespace_error = 0
let g:go_highlight_trailing_whitespace_error = 0
let g:go_highlight_extra_types = 1
let g:go_highlight_operators = 1

" let g:syntastic_go_checkers = ['go', 'golint', 'errcheck']
" let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck']
" let g:syntastic_go_checkers = ['govet', 'errcheck']
" let g:syntastic_go_checkers = ['govet', 'errcheck', 'go']
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

" ==================== go }}}

" ==================== javascript {{{
"
" === vim-javascript
let g:javascript_conceal_function = "ƒ"
let g:javascript_conceal_null = "ø"
let g:javascript_conceal_this = "@"
let g:javascript_conceal_return = "⇚"
let g:javascript_conceal_undefined = "¿"
let g:javascript_conceal_NaN = "ℕ"
let g:javascript_conceal_prototype = "¶"
let g:javascript_conceal_static = "•"
let g:javascript_conceal_super = "Ω"

" === enable features
let g:javascript_plugin_jsdoc = 1
" let g:javascript_enable_domhtmlcss = 1
let g:javascript_plugin_ngdoc = 1
let g:javascript_plugin_flow = 1

" === syntastic
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*

" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 1
" let g:syntastic_check_on_wq = 0
" let g:syntastic_mode_map = { 'mode': 'passive' }
"
" === vue
" autocmd BufNewFile,BufRead *.vue set ft=vue
" autocmd BufNewFile,BufRead *.vue set ft=html
" autocmd BufRead,BufNewFile *.vue set filetype=html
" autocmd FileType vue set filetype=html
"
" === tern
autocmd FileType javascript,jsx nmap <leader>gd :TernDoc<cr>
autocmd FileType javascript,jsx,json,html,css nmap <leader>gv :TernDef<cr>

" === JsBeautify
autocmd FileType javascript nmap <leader>r :call Run()<cr>
autocmd FileType javascript nmap <leader>j :call JsBeautify()<cr>
autocmd FileType jsx        nmap <leader>j :call JsxBeautify()<cr>
autocmd FileType vue        nmap <leader>j :call HtmlBeautify()<cr>
autocmd FileType json       nmap <leader>j :call JsonBeautify()<cr>
autocmd FileType html       nmap <leader>j :call HtmlBeautify()<cr>
autocmd FileType css        nmap <leader>j :call CSSBeautify()<cr>

" === tabs
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2
autocmd FileType json       setlocal shiftwidth=2 tabstop=2
autocmd FileType jsx        setlocal shiftwidth=2 tabstop=2
autocmd FileType html       setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType css        setlocal shiftwidth=2 tabstop=2
autocmd FileType vue        setlocal shiftwidth=2 tabstop=2

" === run
function! Run()
    exec "! babel-node %"
endfunction

" === vim-flow
" typechecking is done automatically on :w
" let g:flow#enable = 0

" ==================== javascript }}}
