" Jake's vimrc
" http://vimdoc.sourceforge.net/htmldoc/options.html

" Enable modelines (NOTE: Be careful -- can be dangerous)
set modeline
set modelines=2

" Number of spaces that a <Tab> in the file counts for
set tabstop=4

" Number of spaces to use for each step of (auto)indent
set shiftwidth=4

" Automatically indent on newlines
set autoindent

" Won't automatically indent when this is pressed
set pastetoggle=<F2>

" Tabs instead of spaces (use CTRL-V <Tab> for a real tab)
set expandtab

" When on, a <Tab> in front of a line inserts blanks
" according to 'shiftwidth'. 'tabstop' is used in other
" places. A <BS> will delete a 'shiftwidth' worth of space
" at the start of the line.
set smarttab

" Show (partial) command in status line
set showcmd

" When a bracket is inserted, briefly jump to the matching
" one. The jump is only done if the match can be seen on the
" screen. The time to show the match can be set with
" 'matchtime'.
set showmatch

" Highlight all matches to a search pattern
set hlsearch

" Ignore case when searching
set ignorecase

" Influences the working of <BS>, <Del>, CTRL-W and CTRL-U in Insert mode.
" indent  allow backspacing over autoindent
" eol     allow backspacing over line breaks (join lines)
" start   allow backspacing over the start of insert
set backspace=indent,eol,start

" Show the line and column number of the cursor position, separated by a comma
set ruler

" Show line numbers
set number

" When set to "dark", Vim will try to use colors that look
" good on a dark background. When set to "light", Vim will
" try to use colors that look good on a light background.
set background=light

" Turn on indentation and syntax highlighting
filetype plugin indent on
syntax on

" We don't need compatibility with vi (also required for with vimwiki)
set nocompatible

" Suffixes that get lower priority when doing tab completion for filenames.
" These are files we are not likely to want to edit or read.
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc,.png,.jpg

" Enable UTF-8
if has("multi_byte")
    " encoding is how vim stores data internally
    set encoding=utf-8
    " fileencoding is the default way of writing files
    setglobal fileencoding=utf-8
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Enforcing *dat* 80 or 100 character line length limit

" Color to use for highlighting:
highlight OverLength ctermbg=gray

" Highlight the part of the line after column 80 (for long lines)
"match OverLength '\%>80v.\+'

" Highlight the 100th column on long lines
2mat OverLength '\%100v.'

" Highlight the 80th column on every line (even short ones)
highlight ColorColumn ctermbg=234
set colorcolumn=80

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Use '[' and ']' keys to switch between tabs
"nnoremap [ :tabp<Enter>
"nnoremap ] :tabn<Enter>
" Use ',' and '.' keys to switch between tabs
nnoremap , :tabp<Enter>
nnoremap . :tabn<Enter>

" Press jk or kj rapidly to exit insert mode
imap jk <Esc>
imap kj <Esc>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Recognize .P as prolog
au BufRead,BufNewFile *.P set filetype=prolog tabstop=4 shiftwidth=4 expandtab smarttab

" Turn off auto line breaking in SML
au BufRead,BufNewFile *.sml set tw=0


" Use just the python checker instead of the pylint checker
let g:syntastic_python_checkers = ['python']
