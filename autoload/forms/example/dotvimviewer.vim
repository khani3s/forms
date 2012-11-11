
function! s:FnameEscape(fname)
  return exists('*fnameescape')
          \ ? fnameescape(a:fname)
          \ : escape(a:fname, " \t\n*?[{`$\\%#'\"|!<")
endfunc

function! s:GetVimHome() 
  if has("win32") || has("dos32") || has("dos16") || has("os2")
    if $HOME != '' 
      let fname = $HOME . "/_viminfo"
    endif
  elseif has("amiga")
    let fname = "s:.vim"
  else
    let fname = $HOME . "/.vim"
  endif

  let fname = s:FnameEscape(fname)
  return fname
endfunction


function! forms#example#dotvimviewer#Make()
  call forms#version()
  let g:forms_log_enabled = 1

  let vimhome = s:GetVimHome() 
  let path = split(vimhome, '/')
  let plen = len(path)

  let node = forms#CreateNode()
  call node.init(path, 0)

  let tree = forms#CreateTree(node)

  let forest = forms#CreateForest()

  " returns list of [name, isleaf] pairs
  function! Generate_sub_path_info(path) dict
    let l:path = '/' . join(a:path, '/')
call forms#log("Generate_sub_path_info path=". string(l:path))
    let files = split(globpath(l:path, "*"), "\n")
call forms#log("Generate_sub_path_info files=". string(files))
    let rval = []
    for file in files
      let isleaf = !isdirectory(file)
      let idx = strridx(file, '/')
      let name = strpart(file, idx+1)
      call add(rval, [name, isleaf])
    endfor
    return rval
  endfunction
  let forest.generateSubPathInfo = function("Generate_sub_path_info")

  function! Has_sub_path_info(path) dict
    let l:path = '/' . join(a:path, '/')
call forms#log("Has_sub_path_info path=". string(l:path))
    let files = split(globpath(l:path, "*"), "\n")
call forms#log("Has_sub_path_info files=". string(files))
    let rval = 0
    for file in files
      if isdirectory(file)
        let rval = 1
        break
      endif
    endfor
    return rval
  endfunction
  let forest.hasSubPathInfo = function("Has_sub_path_info")

  function! Path_to_string(path) dict
    return join(a:path, '/')
  endfunction
  let forest.pathToString = function("Path_to_string")

  function! OnOpenAction(node) dict
    call forms#log("OPEN: ". a:node.name)
  endfunction
  let ooa = forms#newAction({ 'execute': function("OnOpenAction")})

  function! OnCloseAction(node) dict
    call forms#log("CLOSE: ". a:node.name)
  endfunction
  let oca = forms#newAction({ 'execute': function("OnCloseAction")})

  function! OnSelectionAction(node) dict
    call forms#log("SELECT: ". a:node.name)
  endfunction
  let osa = forms#newAction({ 'execute': function("OnSelectionAction")})

  call forest.addTree(tree)

  let attrs = { 'width': 30,
              \ 'height': 15,
              \ 'forest': forest,
              \ 'on_open_action': ooa,
              \ 'on_close_action': oca,
              \ 'on_selection_action': osa
              \ }
  let tv = forms#newForestViewer(attrs)

  let bg = forms#newBackground({ 'body': tv} )

  let form = forms#newForm({'body': bg })
  call form.run()
endfunction

function! forms#example#dotvimviewer#MakeTest()
  call forms#AppendInput({'type': 'Sleep', 'time': 5})
  call forms#AppendInput({'type': 'Exit'})
  call forms#example#dotvimviewer#Make()
endfunction
