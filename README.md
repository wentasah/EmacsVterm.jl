# EmacsVterm

Better integration of Julia REPL with Emacs vterm terminal.

## Installation

1. In Julia prompt type:
   ```
   julia> ]develop https://github.com/wentasah/EmacsVterm.jl
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
  buffer. Currently, this requires [modified `julia-repl` package](https://github.com/wentasah/julia-repl/tree/emacsvterm.jl-integration).
