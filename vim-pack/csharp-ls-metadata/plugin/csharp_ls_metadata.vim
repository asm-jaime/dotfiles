vim9script

# csharp-ls returns csharp:/ URIs for symbols that live only in a DLL.
# Fetch the ILSpy text, write it under ~/.cache/csharp-ls-decompiled/, and
# jump there. Nested jumps from that buffer reuse the original csharp:/ URI.
#
# Do not `import autoload 'lsp/...'` here. Mixing that with yegappan/lsp's
# `import './util.vim'` makes Vim throw E1053 on Ctrl+].

const CACHE_ROOT = $HOME .. '/.cache/csharp-ls-decompiled'
var uriByPath: dict<string> = {}
var materialized: dict<string> = {}

def Sanitize(name: string): string
  var cleaned = substitute(name, '[^A-Za-z0-9._-]\+', '_', 'g')
  cleaned = substitute(cleaned, '^[._-]\+\|[._-]\+$', '', 'g')
  return cleaned == '' ? 'symbol' : cleaned
enddef

def CacheFile(assembly: string, symbolName: string): string
  var dir = CACHE_ROOT .. '/' .. Sanitize(assembly)
  mkdir(dir, 'p')
  return dir .. '/' .. Sanitize(symbolName) .. '.cs'
enddef

def Warn(msg: string)
  echohl WarningMsg
  echomsg msg
  echohl None
enddef

def LocationUri(loc: dict<any>): string
  return loc->get('uri', loc->get('targetUri', ''))
enddef

def SetLocationUri(loc: dict<any>, uri: string)
  if loc->has_key('targetUri')
    loc.targetUri = uri
  else
    loc.uri = uri
  endif
enddef

def UriToPath(uri: string): string
  if uri =~# '^file://'
    return substitute(uri, '^file://', '', '')
  endif
  return uri
enddef

def LocationRange(loc: dict<any>): dict<any>
  return loc->get('range', loc->get('targetSelectionRange', loc->get('targetRange', {})))
enddef

def FindCSharpLs(): dict<any>
  if exists('*lsp#lsp#Server')
    var current = lsp#lsp#Server()
    if !current->empty() && current->get('name', '') =~# '^csharp-ls-' && current->get('ready', false)
      return current
    endif
  endif
  return {}
enddef

def Materialize(lspserver: dict<any>, uri: string): string
  if materialized->has_key(uri)
    return materialized[uri]
  endif
  var reply = lspserver.rpc('csharp/metadata', {textDocument: {uri: uri}},
        {handleError: false})
  if reply->empty() || reply->get('result', {})->empty()
    return ''
  endif
  var info = reply.result
  var path = CacheFile(info->get('assemblyName', 'assembly'),
        info->get('symbolName', 'Symbol'))
  var source = substitute(info->get('source', ''), "\r", '', 'g')
  writefile(split(source, "\n", true), path)
  materialized[uri] = path
  uriByPath[path] = uri
  return path
enddef

def MarkDecompiled(uri: string)
  setbufvar(bufnr(), 'csharp_ls_metadata_uri', uri)
  setlocal readonly nomodifiable noswapfile bufhidden=hide
  setlocal filetype=
  &l:syntax = 'cs'
  nnoremap <buffer> <silent> <C-]> <ScriptCmd>g:CSharpLsGoto(false, 'textDocument/definition')<CR>
  nnoremap <buffer> <silent> g<C-]> <ScriptCmd>g:CSharpLsGoto(true, 'textDocument/definition')<CR>
  nnoremap <buffer> <silent> <leader>i <ScriptCmd>g:CSharpLsGoto(false, 'textDocument/implementation')<CR>
  nnoremap <buffer> <silent> <leader>r <ScriptCmd>g:CSharpLsGoto(false, 'textDocument/references')<CR>
enddef

def OnDecompiledRead()
  var path = expand('%:p')
  if uriByPath->has_key(path)
    MarkDecompiled(uriByPath[path])
  endif
enddef

augroup csharp_ls_metadata
  autocmd!
  autocmd BufNewFile,BufRead *.cs {
    if expand('<afile>:p') =~# '/\.cache/csharp-ls-decompiled/'
      setlocal filetype=
    endif
  }
  autocmd BufReadPost *.cs OnDecompiledRead()
augroup END

def RewriteMetadata(lspserver: dict<any>, loc: dict<any>, quiet: bool): bool
  var uri = LocationUri(loc)
  if uri !~# '^csharp:'
    return true
  endif
  var path = Materialize(lspserver, uri)
  if path == ''
    if !quiet
      Warn('decompiled source was not returned for ' .. uri)
    endif
    return false
  endif
  SetLocationUri(loc, 'file://' .. path)
  loc._csharpMetadataUri = uri
  return true
enddef

def PushTag()
  settagstack(win_getid(), {items: [{
        bufnr: bufnr(),
        from: getpos('.'),
        matchnr: 1,
        tagname: expand('<cword>')}
        ]}, 't')
enddef

def JumpTo(path: string, line0: number, character0: number, open_in_tab: bool)
  if open_in_tab
    execute 'tab split ' .. fnameescape(path)
  else
    execute 'edit ' .. fnameescape(path)
  endif
  setcursorcharpos(line0 + 1, character0 + 1)
  normal! zv
enddef

def OpenLocation(loc: dict<any>, open_in_tab: bool)
  var metadata_uri = loc->get('_csharpMetadataUri', '')
  var path = UriToPath(LocationUri(loc))
  var start = LocationRange(loc)->get('start', {line: 0, character: 0})
  PushTag()
  JumpTo(path, start->get('line', 0), start->get('character', 0), open_in_tab)
  if metadata_uri != ''
    MarkDecompiled(metadata_uri)
  endif
enddef

def ShowLocList(locations: list<dict<any>>, title: string)
  var items: list<dict<any>> = []
  for loc in locations
    var path = UriToPath(LocationUri(loc))
    var start = LocationRange(loc)->get('start', {line: 0, character: 0})
    var lnum = start->get('line', 0) + 1
    var col = start->get('character', 0) + 1
    var text = ''
    if filereadable(path)
      var lines = readfile(path, '', lnum)
      if len(lines) >= lnum
        text = substitute(lines[lnum - 1], '^\s*', '', '')
      endif
    endif
    items->add({filename: path, lnum: lnum, col: col, text: text})
  endfor
  setloclist(0, [], ' ', {title: title, items: items})
  lopen
enddef

def RequestParams(lspserver: dict<any>, method: string): dict<any>
  var params = lspserver.getTextDocPosition(true)
  if exists('b:csharp_ls_metadata_uri')
    params.textDocument.uri = b:csharp_ls_metadata_uri
  endif
  if method == 'textDocument/references'
    params.context = {includeDeclaration: true}
  endif
  return params
enddef

def g:CSharpLsGoto(open_in_tab: bool, method: string = 'textDocument/definition', quiet: bool = false): bool
  var lspserver = FindCSharpLs()
  if lspserver->empty()
    if !quiet
      Warn('C# language server is not ready')
    endif
    return false
  endif

  var reply = lspserver.rpc(method, RequestParams(lspserver, method),
        {handleError: false})
  if reply->empty() || reply->get('result', v:null) == v:null || reply.result->empty()
    var emsg = 'symbol definition is not found'
    if method == 'textDocument/implementation'
      emsg = 'symbol implementation is not found'
    elseif method == 'textDocument/references'
      emsg = 'No references found'
    endif
    if !quiet
      Warn(emsg)
    endif
    return false
  endif

  var result = reply.result
  var locations: list<dict<any>>
  if result->type() == v:t_list
    locations = result
  else
    locations = [result]
  endif

  if lspserver->get('needOffsetEncoding', false)
    locations->map((_, loc) => {
      lspserver.decodeLocation(loc)
      return loc
    })
  endif

  var usable: list<dict<any>> = []
  for loc in locations
    if RewriteMetadata(lspserver, loc, quiet)
      usable->add(loc)
    endif
  endfor
  if usable->empty()
    if !quiet
      Warn('symbol definition is not found')
    endif
    return false
  endif

  var title = 'Definitions'
  if method == 'textDocument/implementation'
    title = 'Implementations'
  elseif method == 'textDocument/references'
    title = 'Symbol References'
  endif

  if method == 'textDocument/references' || usable->len() > 1
    ShowLocList(usable, title)
    return true
  endif

  OpenLocation(usable[0], open_in_tab)
  return true
enddef
