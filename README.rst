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

Installation is easy using the packages feature (see ``:help packages``).

To install the package so that it will automatically load on Vim startup,
use a ``start`` directory, e.g.,

.. code-block::

    mkdir -p ~/.vim/pack/embrace-vim/start
    cd ~/.vim/pack/embrace-vim/start

If you want to test the package first, make it optional instead
(see ``:help pack-add``):

.. code-block::

    mkdir -p ~/.vim/pack/embrace-vim/opt
    cd ~/.vim/pack/embrace-vim/opt

Clone the project to the desired path:

.. code-block::

    git clone https://github.com/embrace-vim/vim-netrw-explore-map.git

If you installed to the optional path, tell Vim to load the package:

.. code-block:: vim

    :packadd! vim-netrw-explore-map

Just once, tell Vim to build the online help:

.. code-block:: vim

    :Helptags

Then whenever you want to reference the help from Vim, run:

.. code-block:: vim

    :help vim-netrw-explore-map

.. |vim-plug| replace:: ``vim-plug``
.. _vim-plug: https://github.com/junegunn/vim-plug

.. |Vundle| replace:: ``Vundle``
.. _Vundle: https://github.com/VundleVim/Vundle.vim

.. |myrepos| replace:: ``myrepos``
.. _myrepos: https://myrepos.branchable.com/

.. |ohmyrepos| replace:: ``ohmyrepos``
.. _ohmyrepos: https://github.com/landonb/ohmyrepos

Note that you'll need to update the repo manually (e.g., ``git pull``
occasionally).

- If you'd like to be able to update from within Vim, you could use
  |vim-plug|_.

  - You could then skip the steps above and register
    the plugin like this, e.g.:

.. code-block:: vim

    call plug#begin()

    " List your plugins here
    Plug 'embrace-vim/vim-netrw-explore-map'

    call plug#end()

- And to update, call:

.. code-block:: vim

    :PlugUpdate

- Similarly, there's also |Vundle|_.

  - You'd configure it something like this:

.. code-block:: vim

    set nocompatible              " be iMproved, required
    filetype off                  " required

    " set the runtime path to include Vundle and initialize
    set rtp+=~/.vim/bundle/Vundle.vim
    call vundle#begin()
    " alternatively, pass a path where Vundle should install plugins
    "call vundle#begin('~/some/path/here')

    " let Vundle manage Vundle, required
    Plugin 'VundleVim/Vundle.vim'

    Plugin 'embrace-vim/vim-netrw-explore-map'

    " All of your Plugins must be added before the following line
    call vundle#end()            " required
    filetype plugin indent on    " required
    " To ignore plugin indent changes, instead use:
    "filetype plugin on

- And then to update, call one of these:

.. code-block:: vim

    :PluginInstall!
    :PluginUpdate

- Or, if you're like the author, you could use a multi-repo Git tool,
  such as |myrepos|_ (along with the author's library, |ohmyrepos|_).

  - With |myrepos|_, you could update all your Git repos with
    the following command:

.. code-block::

    mr -d / pull

- Alternatively, if you use |ohmyrepos|_, you could pull
  just Vim plugin changes with something like this:

.. code-block::

    MR_INCLUDE=vim-plugins mr -d / pull

- After you identify your vim-plugins using the 'skip' action, e.g.:

.. code-block::

    # Put this in ~/.mrconfig, or something loaded by it.
    [DEFAULT]
    skip = mr_exclusive "vim-plugins"

    [pack/embrace-vim/start/vim-netrw-explore-map]
    lib = remote_set origin https://github.com/embrace-vim/vim-netrw-explore-map.git

    [DEFAULT]
    skip = false

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

