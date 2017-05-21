"dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

let mapleader=","
set runtimepath+=~/.config/nvim/bundle/repos/github.com/Shougo/dein.vim
call dein#begin('~/.config/nvim/bundle/')
call dein#add('Shougo/dein.vim')

" quick buffer switcher
call dein#add('jeetsukumaran/vim-buffergator')
nnoremap <leader>z :BuffergatorToggle<CR>

" colorscheme
call dein#add('sjl/badwolf')
colorscheme badwolf

" lazy load nerdtree on first use
call dein#add('scrooloose/nerdtree', {'on_cmd': 'NERDTreeToggle'})
let NERDTreeIgnore = ['\.pyc$']
map <leader>G :NERDTreeFind<CR>

" lazy load Gundo on first use
call dein#add('sjl/gundo.vim', {'on_cmd': 'GundoToggle'})

" lazy load syntax completions on insert mode
call dein#add('Shougo/deoplete.nvim')
call dein#add('zchee/deoplete-go', {'build': 'make'})
call dein#add('zchee/deoplete-clang')
call dein#add('zchee/deoplete-jedi')
call deoplete#enable()
let g:deoplete#sources#jedi#show_docstring = 1

let g:deoplete#sources#go#gocode_binary = '$GOPATH/bin/gocode'
let g:deoplete#sources#go#sort_class = ['package', 'func', 'type', 'var', 'const']
let g:deoplete#sources#go#use_cache = 0
let g:deoplete#sources#go#json_directory = '~/.cache/deoplete/go/$GOOS_$GOARCH'

call dein#add('davidhalter/jedi-vim')
let g:jedi#completions_enabled = 0

" Add the virtualenv's site-packages to vim path
if has('python')
py << EOF
import os.path
import sys
import vim
project_base_dir = os.getcwd()
activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
if os.path.isfile(activate_this):
    sys.path.insert(0, project_base_dir)
    execfile(activate_this, dict(__file__=activate_this))
EOF
if filereadable('bin/python')
    let g:deoplete#sources#jedi#python_path = 'bin/python'
endif
endif

" can't lazy-load because airline needs it
call dein#add('majutsushi/tagbar')

" airline config
call dein#add('vim-airline/vim-airline')
let g:airline_powerline_fonts = 1
let g:airline_detect_modified=1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_min_count = 2

" VCS (cuz airline doesn't do this by itself like powerline did)
call dein#add('tpope/vim-fugitive')

" fuzzy file search
call dein#add('ctrlpvim/ctrlp.vim')
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.(git|hg|svn)|\_site)$',
  \ 'file': '\v\.(exe|so|dll|class|png|jpg|jpeg|pyc)$',
\}
map <C-t> :CtrlPBufTag<CR>

" comment/uncomment via ,#
call dein#add('scrooloose/nerdcommenter')

" sane extensions of vim mappings
call dein#add('tpope/vim-surround')
call dein#add('tpope/vim-repeat')

call dein#add('vim-syntastic/syntastic')

" snippets
call dein#add('Shougo/neosnippet')
call dein#add('Shougo/neosnippet-snippets')

let g:neocomplete#enable_at_startup = 1
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

call dein#end()

" Required:
filetype plugin indent on
syntax enable

" install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

"End dein Scripts-------------------------

set termguicolors
set mouse=a

" remember cursor position next time we open the file
if has("autocmd")
	au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" shows results of a command as you type
if exists('&inccommand')
  set inccommand=split
endif

" show a little context while scrolling
set scrolloff=5

" everything tabby is 4 spaces
set tabstop=4
set shiftwidth=4

" show line numbers relative to current line
set relativenumber
set number

" set F12 to toggle paste mode
set pastetoggle=<F12>

" use the clipboards of vim and system
set clipboard+=unnamed 

" F key mappings
map <F1> <Nop>
map <F1> :NERDTreeToggle<CR>
map <F2> :TagbarToggle<CR>
map <F3> :GundoToggle<CR>

" misc leader key mappings
nnoremap <leader>q :bd<CR>

" neocomplete like
set completeopt+=noinsert
" deoplete.nvim recommend
set completeopt+=noselect

" Toggle linenumbers
function! NumberToggle()
  if(&relativenumber == 1)
    set norelativenumber
	set nonumber
	set nolist
  else
    set relativenumber
	set number
	set list
  endif
endfunc
map <F11> :call NumberToggle()<CR>
