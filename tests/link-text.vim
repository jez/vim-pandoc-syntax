" From this repository: vim -Nu NONE -n -es -S tests/link-text.vim
" Or: nvim --headless -u NONE -n -S tests/link-text.vim
set rtp^=.
syntax on
set spell spelllang=en
for conceal in [0, 1]
  let g:pandoc#syntax#conceal#use = conceal
  enew!
  let cases = [
        \ ['[Some **bold** and *italic* and `code` text.](#foo)', 'bold', 'pandocStrongInLink'],
        \ ['[Some **bold** and *italic* and `code` text.](#foo)', 'italic', 'pandocEmphasisInLink'],
        \ ['[Some **bold** and *italic* and `code` text.](#foo)', 'code', 'pandocNoFormatted'],
        \ ['Some **bold** and *italic* and `code` text.', 'bold', 'pandocStrong'],
        \ ['Some **bold** and *italic* and `code` text.', 'italic', 'pandocEmphasis'],
        \ ['[__bold__ and _italic_](#foo)', 'bold', 'pandocStrongInLink'],
        \ ['[__bold__ and _italic_](#foo)', 'italic', 'pandocEmphasisInLink'],
        \ ['[***both***](#foo)', 'both', 'pandocStrongEmphasisInLink'],
        \ ['[___both___](#foo)', 'both', 'pandocStrongEmphasisInLink'],
        \ ['[*outer **nested** outer*](#foo)', 'nested', 'pandocStrongInEmphasisInLink'],
        \ ['[**outer *nested* outer**](#foo)', 'nested', 'pandocEmphasisInStrongInLink'],
        \ ['- [**bold**](#foo)', 'bold', 'pandocStrongInLink'],
        \ ['[*italic*][ref]', 'italic', 'pandocEmphasisInLink'],
        \ ['![**bold**](image.png)', 'bold', 'pandocStrongInLink'],
        \ ['[`**literal** [bracket]` and **bold**](#foo)', 'literal', 'pandocNoFormatted'],
        \ ['[`**literal** [bracket]` and **bold**](#foo)', 'bold', 'pandocStrongInLink']]
  call setline(1, map(copy(cases), 'v:val[0]'))
  call append('$', '[speling **speling** *speling* `speling`](speling)')
  set syntax=pandoc
  syntax sync fromstart
  for i in range(len(cases))
    let col = match(cases[i][0], cases[i][1]) + 1
    call assert_equal(cases[i][2], synIDattr(synID(i + 1, col, 1), 'name'), cases[i][0])
  endfor
  let col = 0
  for checked in [1, 1, 1, 0, 0]
    let col = match(getline('$'), 'speling', col) + 1
    call cursor(line('$'), col)
    call assert_equal(checked ? ['speling', 'bad'] : ['', ''], spellbadword(), 'spell column ' . col)
  endfor
endfor
if isdirectory('../vim-colors-solarized')
  set rtp^=../vim-colors-solarized
  colorscheme solarized
  for [group, bold, italic] in [
        \ ['pandocEmphasisInLink', 0, 1], ['pandocStrongInLink', 1, 0],
        \ ['pandocStrongEmphasisInLink', 1, 1],
        \ ['pandocStrongInEmphasisInLink', 1, 1], ['pandocEmphasisInStrongInLink', 1, 1]]
    let id = synIDtrans(hlID(group))
    call assert_equal(synIDattr(synIDtrans(hlID('pandocReferenceLabel')), 'fg', 'gui'), synIDattr(id, 'fg', 'gui'), group)
    call assert_equal(bold, synIDattr(id, 'bold', 'gui') ==# '1' ? 1 : 0, group)
    call assert_equal(italic, synIDattr(id, 'italic', 'gui') ==# '1' ? 1 : 0, group)
  endfor
  " Every existing bldi use represents emphasis, including within bold headings.
  for group in ['pandocEmphasisNestedDefinition',
        \ 'pandocStrongEmphasisNestedDefinition', 'pandocStrongEmphasisEmphasisDefinition',
        \ 'pandocEmphasisNestedTable', 'pandocStrongEmphasisNestedTable',
        \ 'pandocStrongEmphasisEmphasisTable', 'pandocEmphasisHeading',
        \ 'pandocEmphasisNestedHeading', 'pandocStrongEmphasisNestedHeading',
        \ 'pandocStrongEmphasisEmphasisHeading', 'pandocEmphasisNested',
        \ 'pandocStrongEmphasis', 'pandocStrongInEmphasis', 'pandocEmphasisInStrong',
        \ 'pandocStrongEmphasisNested', 'pandocStrongEmphasisEmphasis']
    call assert_equal('1', synIDattr(hlID(group), 'bold', 'gui'), group)
    call assert_equal('1', synIDattr(hlID(group), 'italic', 'gui'), group)
  endfor
endif
if !empty(v:errors)
  for error in v:errors
    echom error
  endfor
  cquit
endif
qa!
