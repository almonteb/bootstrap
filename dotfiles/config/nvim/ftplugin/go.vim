let g:deoplete#sources#go#gocode_binary = '$GOPATH/bin/gocode'
let g:deoplete#sources#go#sort_class = ['package', 'func', 'type', 'var', 'const']
let g:deoplete#sources#go#use_cache = 0
let g:deoplete#sources#go#json_directory = '~/.cache/deoplete/go/$GOOS_$GOARCH'

let g:go_def_mapping_enabled = 0

map <buffer> <leader>g :GoImplements<CR>
map <buffer> <leader>n :GoDef<CR>
map <buffer> <leader>p :GoInfo<CR>
