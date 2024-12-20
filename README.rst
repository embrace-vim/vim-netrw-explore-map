##############################################
Convenient Netrw ``:Explore`` Map Commands  🐾
##############################################

Wire convenient ``:Explore [dir]`` command maps.

Initialization
==============

Your Vim config must initialize the plugin, otherwise it won't do anything.

Call something like this from your Vim config:

.. code-block::

  let notable_notes_mappings = [
    \   ["<Leader>p", "~/path/to/dir1"],
    \   ["<Leader>P", "~/path/to/dir2"],
    \   ["<Leader><M-p>", "~/path/to/dir3"],
    \   ["<Leader><M-P>", "~/path/to/dir4"],
    \ ]

  call g:embrace#explore#CreateMapsAndSetupNetrw(notable_notes_mappings)

This will create 4 maps:

- ``\p`` will explore ``~/path/to/dir1``.

- ``\P`` will explore ``~/path/to/dir2``.

- ``\<Alt-p>`` will explore ``~/path/to/dir3``.

- ``\<Alt-P>`` will explore ``~/path/to/dir4``.

Dependencies
============

This plugin uses a command from ``embrace-vim/vim-buffer-delights``
to avoid opening files in a special buffer:

https://github.com/embrace-vim/vim-buffer-delights 🍧

This plugin will issue a single warning if the ``vim-buffer-delights``
plugin is not installed, but it will otherwise work.

- You can disable the warning with a global variable:

.. code-block::

  let g:vim_buffer_delights_alerts_disable = 1

The ``vim-buffer-delights`` plugin will wire a number of window and
buffer command maps, which you can disable with a global variable:

.. code-block::

  let g:vim_buffer_delights_disable = 1

Hints
=====

The author uses maps like these to explore a directory of symlinks,
where each symlink is prefixed "00", "01", etc., and each symlink
points to a text file that I often edit.

Then, when you run the map command (e.g., ``\p`` from the example above),
you can:

- Look at file you want to open.

- Type the number indicated.

- Hit the down arrow.

- Press ``<Enter>`` to open the file.

E.g., ``\p4↓<CR>`` takes 5 keystrokes to open a specific file.

This plugin is just one example of many options for opening commonly
edited files:

- You could wire a Vim ``map`` to the specific file.

  - E.g., you could wire ``<Alt-p>``::

      nnoremap <M-p> :e ~/path/to/dir1/file<CR>

- You could instead use an OS accelerator mapping.

  - E.g., using `Hammerspoon <https://www.hammerspoon.org/>`__,
    and |gvim-open-kindness|_ 🐬, you could wire ``<Alt-p>``::

      local alt_p = hs.hotkey.bind({"alt"}, "P", function()
        gvim_open_kindness("~/path/to/dir1/file")
      end)

.. |gvim-open-kindness| replace:: ``gvim-open-kindness``
.. _gvim-open-kindness: https://github.com/DepoXy/gvim-open-kindness

- You could use a fuzzy-finder, such as ``junegunn/fzf.vim``:

  https://github.com/junegunn/fzf

  https://github.com/junegunn/fzf.vim

In the first two examples above, it takes just one keystroke to open
the file, but if you have lots of files you'd like easy access to,
you might quickly run out of convenient bindings. Or you might not
remember them all!

By using ``vim-netrw-explore-map``, we hope it makes it easier to
quickly find and open your favorite text files.

Installation
============

.. |help-packages| replace:: ``:h packages``
.. _help-packages: https://vimhelp.org/repeat.txt.html#packages

.. |INSTALL.md| replace:: ``INSTALL.md``
.. _INSTALL.md: INSTALL.md

Take advantage of Vim's packages feature (|help-packages|_)
and install under ``~/.vim/pack``, e.g.,:

.. code-block::

  mkdir -p ~/.vim/pack/embrace-vim/start
  cd ~/.vim/pack/embrace-vim/start
  git clone https://github.com/embrace-vim/vim-netrw-explore-map.git

  " Build help tags
  vim -u NONE -c "helptags vim-netrw-explore-map/doc" -c q

- Alternatively, install under ``~/.vim/pack/embrace-vim/opt`` and call
  ``:packadd vim-netrw-explore-map`` to load the plugin on-demand.

For more installation tips — including how to easily keep the
plugin up-to-date — please see |INSTALL.md|_.

Attribution
===========

.. |embrace-vim| replace:: ``embrace-vim``
.. _embrace-vim: https://github.com/embrace-vim

.. |@landonb| replace:: ``@landonb``
.. _@landonb: https://github.com/landonb

The |embrace-vim|_ logo by |@landonb|_ contains
`coffee cup with straw by farra nugraha from Noun Project
<https://thenounproject.com/icon/coffee-cup-with-straw-6961731/>`__
(CC BY 3.0).

