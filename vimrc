" general settings 
let $LANG='en'
let mapleader=','
set langmenu=none
set nocompatible
set backspace=2
filetype on
filetype plugin on
set noeb
syntax on
set t_Co=256
set cmdheight=2
set showcmd
set ruler
set number
set termencoding=utf-8
set encoding=utf8
set fileencodings=utf8,ucs-bom,gbk,cp936,gb2312,gb18030
scriptencoding utf-8
set noswapfile

set laststatus=2
set statusline=%<%f\
set statusline+=%w%h%m%r
set statusline+=%{fugitive#statusline()}
set statusline+=\ [%{&ff}/%Y]
set statusline+=\ [%{getcwd()}]
set statusline+=%=%-14.(%l,%c%V%)\ %p%%
set tags=./.tags;,.tags

" load plugins
if filereadable(expand('~/.vimrc.plug'))
    source ~/.vimrc.plug
endif

set cursorline
highlight clear SignColumn
highlight clear LineNr

set whichwrap+=<,>,h,l
set ttimeoutlen=0
set virtualedit=block,onemore
set mouse=a                 " Automatically enable mouse usage
set mousehide               " Hide the mouse cursor while typing
set background=dark
color gruvbox
set showmode
set tabpagemax=15
filetype plugin indent on

" search
set hlsearch
set incsearch
set ignorecase

if has('clipboard')
    if has('unnamedplus')
        set clipboard=unnamed,unnamedplus
    else 
        set clipboard=unnamed
    endif
endif

set shortmess+=filmnrxoOtT
set viewoptions=folds,options,cursor,unix,slash
set history=1000
set spell
set hidden
set iskeyword-=.
set iskeyword-=#
set iskeyword-=-

" indent and formatting
set nowrap
set shiftwidth=4
set expandtab
set tabstop=4
set softtabstop=4
set nojoinspaces
set splitright
set splitbelow
set pastetoggle=<F12>
set autoindent
set smartindent
set cindent
autocmd FileType make set noexpandtab

function! GoogleCppIndent()
	let l:cline_num = line('.')
	let l:orig_indent = cindent(l:cline_num)
	if l:orig_indent == 0 | return 0 | endif

	let l:pline_num = prevnonblank(l:cline_num - 1)
	let l:pline = getline(l:pline_num)
	let l:pline_indent = indent(l:pline_num)
	if l:pline =~# '^\s*template' | return l:pline_indent | endif
	if l:orig_indent != &shiftwidth | return l:orig_indent | endif

	let l:in_comment = 0
	let l:pline_num = prevnonblank(l:cline_num - 1)
	while l:pline_num > -1
		let l:pline = getline(l:pline_num)
		let l:pline_indent = indent(l:pline_num)

		if l:in_comment == 0 && l:pline =~ '^.\{-}\(/\*.\{-}\)\@<!\*/'
			let l:in_comment = 1
		elseif l:in_comment == 1
			if l:pline =~ '/\*\(.\{-}\*/\)\@!'
				let l:in_comment = 0
			endif
		elseif l:pline_indent == 0
			if l:pline !~# '\(#define\)\|\(^\s*//\)\|\(^\s*{\)'
				if l:pline =~# '^\s*namespace.*'
					return 0
				else
					return l:orig_indent
				endif
			elseif l:pline =~# '\\$'
				return l:orig_indent
			endif
		else
			return l:orig_indent
		endif

		let l:pline_num = prevnonblank(l:pline_num - 1)
	endwhile

	return l:orig_indent
endfunction

let b:undo_indent = "setl sw< ts< sts< et< tw< wrap< cin< cino< inde<"
autocmd FileType c,cpp set sw=2 ts=2 sts=2 wrap et cino=j1,h1,l1,g1,t0,i4,+4,(0,W4,w1 indentexpr=GoogleCppIndent()
autocmd FileType scheme set sw=2 ts=2 sts=2 lisp ai
autocmd FileType c,cpp let g:indent_guides_start_level=2

autocmd BufNewFile,BufRead *.html.twig set filetype=html.twig
autocmd FileType haskell,puppet,ruby,yaml,yml setlocal expandtab shiftwidth=2 softtabstop=2
autocmd BufNewFile,BufRead *.coffee set filetype=coffee
autocmd FileType haskell setlocal commentstring=--\ %s
autocmd FileType haskell,rust setlocal nospell

"mapping
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_
map <C-L> <C-W>l<C-W>_
map <C-H> <C-W>h<C-W>_
noremap j gj
noremap k gk

map <F5> :call CompileRunGcc()<CR>
func! CompileRunGcc()
    exec "w"
    if &filetype == 'c'
        :AsyncRun cc % -o %< && ./%<
    elseif &filetype == 'cpp'
        :AsyncRun c++ --std=c++1y -lpthread -lfolly -lglog % -o %< && ./%<
    elseif &filetype == 'java'
        :AsyncRun javac % && java %<
    elseif &filetype == 'sh'
        :AsyncRun ./%
    elseif &filetype == 'python'
        :AsyncRun time python %
    elseif &filetype == 'go'
        :AsyncRun go run %
    endif
endfunc
