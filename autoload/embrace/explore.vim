" vim:tw=0:ts=2:sw=2:et:norl:
" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/embrace-vim/vim-netrw-explore-map#🥾
" License: vim-netrw-map by Landon Bouma is marked with CC0 1.0
"   https://creativecommons.org/publicdomain/zero/1.0/
"   Copyright © 2021-2024 Landon Bouma.

" -------------------------------------------------------------------

" SAVVY/2020-07-13: Beware using '$' in a filename.
" - If you call :Explore with '$' in the filename, netrw substitutes 'hBc'.
" - The netrw docs says it uses shellescape() and fnameescape(), but
"   I nonetheless have issues with that character.
" - The netrw doc also says:
"     “Still, my advice is, if the 'filename' looks like a vim command
"      that you aren't comfortable with having executed, don't open it.”
"   Albeit that's under a section on Network-Oriented File Transfer
"   (netrw-xfer), i.e., ftp.
"   - But I think the comment 'still' applies to normal `netrw`, at
"     least in my experience.
" - SAVVY: Point being, don't use '$' in any notable-notes filenames.

" -------------------------------------------------------------------

" This plugin use global mappings (works in all buffers).
"
" - Note that I had thought about wiring each buffer separately, e.g.,
"     autocmd BufEnter :call s:GenerateMapsFromUserVariable()
"   and then using `noremap <buffer> ...`.
"   - I originally wanted to avoid wiring these netrw calls for special
"     windows, because opening netrw in a special window is somewhat
"     unexpected, or at least undesired, and it's inelegant. The special
"     buffer disassociates from its window, and the user has to close the
"     window and reopen the special buffer to fix the situation.
"
" - So I experimented with *not* wiring the netrw commands from special
"   buffers, trying my best to get BufEnter to work. I thought I didn't
"   want the user to be able to invoke the feature from the Project Tray
"   window, the Quickfix window, or a Help window. But this posed a few
"   issues:
"   - Not all special buffers can be identified on the first BufEnter.
"     - E.g., on the first BufEnter, the Project Tray buffer is buflisted,
"       just like a normal buffer. It also has no filetype, just like a
"       normal new file, and we want to allow the user to open netrw from
"       a new file buffer, so we can't use lack of filetype to tell us
"       anything. Basically, it's difficult to identify the Project Tray
"       buffer on the first BufEnter.
"     - We could check the filename associated with a buffer, e.g., the
"       Project Tray generally loads a file named `.vimprojects`, but I
"       didn't want to couple the feature to any particular filenames.
"     - I also tried setting a filetype on the Project Tray buffer when it
"       is created, but this script's BufEnter runs before the value is set.
"       - Also, by setting the filetype, it breaks syntax highlighting --
"         the moment you move the cursor into the Project Tray, highlights
"         disappear. (I don't quite get why; the plugin calls `syntax match`
"         in the context of the buffer, but maybe that only works without a
"         filetype, and once you set a filetype, the next time BufEnter is
"         called, e.g., when you move the cursor to the Project Tray, Vim
"         resets syntax highlighting and looks for a syntax file to load
"         (and in this case doesn't find one). So the only way for those
"         `syntax match` calls to persist is to not set a filetype.)
"   - Another issue is that it's convenient to activate netrw from anywhere.
"     Otherwise the user has to move the cursor to a different window first
"     and then call netrw. Or they try to call netrw without remembering
"     that they're in a special buffer window, and it interrupts their flow
"     because nothing happens.
"
" - So we'll wire the netrw commands so they're usable from any buffer/window.
"   - And we won't care whether the current buffer is special or not, until
"     the user uses one of the netrw commands, at which point we'll make
"     sure not to invoke netrw in a special window but to find a normal
"     window instead.

" -------------------------------------------------------------------

" - Note that `netrw` whines on Enter if Vim still in Insert mode:
"     `E21: Cannot make changes, 'modifiable' is off.`
"   - So using <C-O> does not work, e.g.,
"       inoremap <buffer> <silent> <Leader>p
"         \ <C-O>:Explore /path/to/notable-notes<CR>
"     will start netrw in Insert mode, and pressing Enter won't work.
"   - So use <ESC> in the insert mode maps to leave Insert mode.

function! s:WireMappingExploreWithMRU(binding, dirpath) abort
  silent exec "silent! unmap <buffer> " . a:binding
  silent exec "silent! iunmap <buffer> " . a:binding

  silent exec "noremap <silent> <unique> " . a:binding
    \ . " :call <SID>ExploreWithMRU('" . a:dirpath . "')<CR>"
  silent exec "inoremap <silent> <unique>" . a:binding
    \ . " <ESC>:call <SID>ExploreWithMRU('" . a:dirpath . "')<CR>"
endfunction

" -------------------------------------------------------------------

function! s:GenerateMapsFromUserVariable(explore_maps) abort
  for l:mapping in a:explore_maps
    if len(l:mapping) == 2 && len(l:mapping[0]) && len(l:mapping[1])
      call s:WireMappingExploreWithMRU(l:mapping[0], l:mapping[1])
    else
      echom "ALERT: Your a:explore_maps array is misconfigured."
    endif
  endfor
endfunction

" -------------------------------------------------------------------

" WINDOW MANAGEMENT LOGIC
"
" - Prefer opening netrw in an existing netrw window.
" - Do not replace any other special buffer with netrw.
" - Remember the buffer being replaced so user can <ESC> back.

" Prefer opening netrw in existing netrw window.
" - If the user previously opened a netrw buffer but navigated away,
"   such that a netrw window is still open, find that window and reuse
"   it.

" Do not replace any other special buffer with netrw.
" - Except for an existing netrw window, don't open netrw in a window
"   that contains a special buffer.
"   - E.g., don't run netrw in the Project Tray, or the Quickfix window.
"     - The Project Tray is a very narrow window, and loading netrw in't
"       is not very useful (user would have to resize the window manually,
"       and for the most part, Dubs Vim manages all window sizing so you
"       don't have to).
"     - The Quickfix window is usually a very short window across the
"       bottom of the Vim window that might also be very wide, and loading
"       netrw therein is not very useful, either, because the user would
"       generally then need to resize and reposition the window if they
"       wanted to open a file in it for editing.
"     - In either case, clobbering the Project Tray or Quickfix with
"       another file is usually a mistake that'll cause the user to
"       close that window and then reopen the special buffer. So be
"       preemptive and avoid clobbering such windows with netrw.

" Remember the buffer netrw replaces so user can <ESC> back.
" - The user can already close the netrw file (e.g., Alt-f c, or :Bdelete),
"   but netrw does not maintain the so-called *alternative file*, so rather
"   than the previous buffer being reloaded when netrw is closed, the buffer
"   that was open before the previous buffer is loaded.
" - For the same reason, pressing CTRL-^ in the netrw window does not work
"   as expected. Normally, CTRL-^ edits *the alternative file. Mostly the
"   alternative file is the previously edited file. This is a quick way to
"   toggle between two files,* says the Vim doc.
"   - But from a netrw window, which doesn't update the alternative file,
"     when you press CTRL-^, rather than jump to the buffer you had open
"     before opening netrw, Vim jumps to the buffer before that.
"     - E.g., if you open buffer 1, then switch to buffer 2,
"       and then run :Explore, a CTRL-^ returns to buffer 1.

" Here we implement the aforementioned logic:
" - First look for an open netrw window and switch to it.
"   - If there's no netrw window, find the first window, starting with
"     the current window, that does not contain a special buffer.
"   - If there's no window without a special buffer, open a new window.
" - Then remember the current buffer in the window before loading netrw,
"   so the user can press <Esc> to return to that buffer.
" - Finally, call :Explore to open the netrw window.
"   - Note that using quotes changes the behavior, e.g.,
"     `:Explore <path>` vs. `:Explore '<path>'`.
"     - I didn't find docs or suss out exact behavior, but with quotes,
"       :Explore seems to ignore '<path>' and opens a different path.
"     - So just don't use quotes.
function! s:ExploreWithMRU(explore_dir)
  " Always look for existing netrw window and replace buffer therein.
  if !s:MoveCursorToFirstNetrwWindow()
    " No netrw window, so move cursor to a window with a normal buffer.
    call s:MoveCursorToFirstNormalWindow()
    " Remember current buffer so user can <Escape> back to it from netrw.
    " (We don't do if already netrw window, because we don't want to jump
    "  back to another netrw buffer.)
    let s:notable_notes_mru_bufnr = bufnr("%")
  endif
  " Call :Explore to load the netrw window with the specified path.
  exec "Explore " . a:explore_dir
endfunction

" -------------------------------------------------------------------

function! s:MoveCursorToFirstNetrwWindow() abort
  let l:success = 0

  let l:final_winnr = winnr('$')

  for l:visit_winnr in range(1, l:final_winnr)
    let l:bufnr = winbufnr(l:visit_winnr)

    if getbufvar(l:bufnr, "&ft") == 'netrw'
      " Jump to the netrw window we located.
      exec l:visit_winnr . 'wincmd w'

      let l:success = 1

      break
    end
  endfor

  return l:success
endfunction

" -------------------------------------------------------------------

" Avoid opening netrw in a special buffer window, because it's annoying.
" - Such windows are generally not sized appropriately (e.g., the Project
"   Tray window is very narrow, and the Quickfix window is generally short
"   and very wide and located at the bottom of the Vim window).
" - It's generally a mistake to clobber a special buffer (not generally
"   what the user wants or expects), and to recover, the user needs to
"   close the window and reopen the special buffer. So just don't do it.
"
" Here we search the list of windows, starting with the current window
" and working our way clockwise through the windows, moving the cursor
" to the first window that does not contain a special buffer.
" - The idea is to support the :Explore calls from all buffers, including
"   special buffers. And we only send the new netrw buffer to a normal
"   window; we will not replace a special buffer or use its window.
" - E.g., if the user is editing one file and has the Project Tray open,
"   and they action one of our bindings from the Project Tray, send the
"   netrw buffer to the other window.

if !exists('g:vim_buffer_delights_alerts_disable')
  let g:vim_buffer_delights_alerts_disable = 0
endif

let s:has_alerted_vim_buffer_delights = 0

function! s:MoveCursorToFirstNormalWindow() abort
  " CXREF:
  " ~/.vim/pack/embrace-vim/start/vim-buffer-delights/autoload/embrace/windows.vim
  try
    let l:found_winnr = g:embrace#windows#FindNextWindowWithNormalBuffer()
  catch /^Vim\%((\a\+)\)\=:E117:/
    " E.g., E117: Unknown function: foo#bar#baz
    if !g:vim_buffer_delights_alerts_disable && !s:has_alerted_vim_buffer_delights
      echom "ALERT: Please install embrace-vim/vim-buffer-delights to enable `FindNextWindowWithNormalBuffer`:"
      echom "  https://github.com/embrace-vim/vim-buffer-delights#🍧"

      let s:has_alerted_vim_buffer_delights = 1
    endif

    let l:found_winnr = winnr()
  endtry

  if l:found_winnr > 0
    " Move the cursor to the next window identified without a special buffer.
    exec l:found_winnr . 'wincmd w'
  else
    " No window was identified without a special buffer, e.g., the user might
    " just have the Project Tray and Quickfix open, or maybe just a Help doc.
    " - Open a new window.
    new
  endif
endfunction

" -------------------------------------------------------------------

" Just a little convenience: Close/bail from netrw on ESCape.
" - Note: Prefer <CTRL-^> command over `edit`. While the two commands work
"   similarly, e.g., `123<CTRL-^>` and `edit #123` both start editing buffer
"   #123, the `edit` commands fails if the buffer does not have a file name.
"   - Specifically, `edit #123` does not work if the buffer is a new file or
"     an unnamed file. E.g., this won't return to a new/unnamed file:
"       autocmd FileType netrw noremap <buffer> <silent>
"         \ <ESC> :exec "edit #" . s:notable_notes_mru_bufnr<CR>
"     So use CTRL-^ command.
" - Note: I could not get map with {rhs} exec and special character to work.
"   - You can run `:exec "normal! \<C-^>"` manually from from the command line.
"     But when called from a map, the <C-^> is removed, e.g., with:
"       autocmd FileType netrw nnoremap <ESC> :exec "normal! \<C-^>"<CR>
"     If you press Escape, Vim will complain:
"       E114: Missing quote: "normal! \"
"   - Note that a simple map (without :exec) works, e.g.,:
"       nnoremap <ESC> <Char-0x1E>
"     But we want to add the buffer number, so we need to call exec.
"   - Some work arounds I tried that didn't work:
"     - The <Ctrl-V><Ctrl-^> trick prints . Didn't work.
"     - The character code (:h map-special-chars) is <Char-0x1E>.
"       - Also didn't work: <Char-0x1E> \<Char-0x1E> \\<Char-0x1E> etc,
"         quoted or not.
"     - Use the <special> option, e.g.,
"         autocmd FileType netrw nnoremap <special> <ESC> ...
"   - What finally worked was calling a function to do the dirty work.
"     - Then any of the character representations work, e.g.,:
"         exec "normal " . s:notable_notes_mru_bufnr . ""
"         exec "normal " . s:notable_notes_mru_bufnr . "\<C-^>"
"         exec "normal " . s:notable_notes_mru_bufnr . "\<Char-0x1E>"
" - Finally, just as a Vim reminder, because I go months between editing
"   Vimscripts sometimes and forget all the tricks, you could remove the
"   augroup and move the autocommand to an ftplugin file, e.g.,:
"     $ echo 'nnoremap <ESC> :call FooBarBack()<CR>' > ftplugin/netrw_mappings.vim
function! s:CreateAutocmdFiletypeNetrw() abort
  augroup ExploreNotableNotes
    autocmd!

    " Wire <ESC> from netrw buffer.
    autocmd FileType netrw nnoremap <buffer> <silent> <ESC> :call <SID>EscapeFromNetrwBuffer()<CR>
  augroup End
endfunction

" ***

function! s:EscapeFromNetrwBuffer()
  exec "normal " . s:notable_notes_mru_bufnr . "\<C-^>"
endfunction

" -------------------------------------------------------------------

function! g:embrace#explore#CreateMapsAndSetupNetrw(explore_maps) abort
  if empty(a:explore_maps)
    echom "ALERT: Please pass list of [seq, path] lists to use this plugin."

    return
  endif

  call s:CreateAutocmdFiletypeNetrw()

  " Wire the global mappings.
  call s:GenerateMapsFromUserVariable(a:explore_maps)
endfunction

