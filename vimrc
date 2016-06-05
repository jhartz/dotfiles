" Jake's vimrc

" http://vimdoc.sourceforge.net/htmldoc/options.html

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

" Highlight lines longer than 80 characters
"match Error '\%>80v.\+'

filetype plugin indent on
syntax on

" Use '[' and ']' keys to switch between tabs
"nnoremap [ :tabp<Enter>
"nnoremap ] :tabn<Enter>
nnoremap , :tabp<Enter>
nnoremap . :tabn<Enter>

" Press jk or kj rapidly to exit insert mode
imap jk <Esc>
imap kj <Esc>
