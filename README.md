# EmacsVterm

Better integration of Julia REPL with Emacs vterm terminal.

## Installation

1. In Julia prompt type:
   ```
   julia> ]add EmacsVterm
   ```

2. Add the following to `~/.julia/config/startup.jl`:

   ```julia
   atreplinit() do repl
       @eval using EmacsVterm
   end
   ```

3. Configure [julia-repl](https://github.com/tpapp/julia-repl) to use
   the `vterm` backend by putting:

   ```elisp
   (julia-repl-set-terminal-backend 'vterm)
   ```
   to your Emacs config.

## Features

- You can jump between prompts in `*julia*` REPL buffers with `C-c
  C-p` and `C-c C-n`.

- Julia REPL informs Emacs about its working directory. Therefore,
  after changing directory in Julia, opening file in Emacs (e.g. `C-x
  C-f`) starts in that directory.

- Documentation (`@doc ...` invocation or `C-c C-d` in `julia-mode`
  buffers with `julia-repl` enabled) is shown in separate Emacs
  buffer. Currently, this requires [modified `julia-repl` package](https://github.com/tpapp/julia-repl/pull/112/files).

  If you are not happy with where Emacs chooses to display the
  `*julia-doc*` buffer, you can configure it with via a "display
  action". For example, the following piece of code in `init.el`
  ensures that if the `*julia-doc*` buffer is already shown somewhere,
  the same buffer is reused; otherwise, a right side window with an
  appropriate width will be created.

  ```elisp
  (add-to-list 'display-buffer-alist '("\\*julia-doc\\*"
				       (display-buffer-reuse-window display-buffer-in-side-window)
				       (side . right) (window-width . 80)))
  ```
