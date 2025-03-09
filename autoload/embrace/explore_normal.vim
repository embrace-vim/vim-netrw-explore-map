" vim:tw=0:ts=2:sw=2:et:norl:
" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/embrace-vim/vim-netrw-explore-map#🥾
" License: vim-buffer-delights by Landon Bouma is marked with CC0 1.0
"   https://creativecommons.org/publicdomain/zero/1.0/
"   Copyright © 2020, 2024 Landon Bouma.

" -------------------------------------------------------------------

function! g:embrace#explore_normal#IsNormalBuffer(bufnr) abort
  let l:bufnr = bufnr(a:bufnr)

  let l:ftype = getbufvar(l:bufnr, "&filetype")

  if 0
    \ || getbufvar(l:bufnr, '&buftype') != ''
    \ || getbufvar(l:bufnr, "&previewwindow")
    \ || !getbufvar(l:bufnr, "&modifiable")
    \ || !buflisted(l:bufnr)
    \ || l:ftype == 'qf'
    \ || l:ftype == 'git'
    \ || l:ftype == 'fugitiveblame'
    \ || bufname(l:bufnr) == '-MiniBufExplorer-'

    return 0
  endif

  return 1
endfunction

" -------------------------------------------------------------------

function! g:embrace#explore_normal#FindNextWindowWithNormalBuffer(start_winnr = 0) abort
  let l:found_winnr = 0

  let l:final_winnr = winnr('$')

  if a:start_winnr == 0
    let l:start_winnr = winnr()
  elseif a:start_winnr > l:final_winnr
    let l:start_winnr = 1
  else
    let l:start_winnr = a:start_winnr
  endif

  let l:visit_winnr = l:start_winnr

  while l:visit_winnr <= l:final_winnr
    let l:bufnr = winbufnr(l:visit_winnr)

    if g:embrace#explore_normal#IsNormalBuffer(l:bufnr)
      " All good!
      let l:found_winnr = l:visit_winnr

      break
    endif

    " Didn't break, so window contains the project tray, help, quickfix, or
    " preview, etc. Skip current window and while again to test next window.
    let l:visit_winnr += 1

    " Check if we've passed the last window and should reset to first window.
    if l:visit_winnr > l:final_winnr
      let l:visit_winnr = 1
    endif

    " Check if we've wrapped around back to the start.
    if l:visit_winnr == l:start_winnr
      break
    endif
  endwhile

  return l:found_winnr
endfunction

" -------------------------------------------------------------------
