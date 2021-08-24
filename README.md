# EmacsVterm

## Usage

Add the following to `~/.julia/config/startup.jl`:

```julia
atreplinit() do repl
    @eval using EmacsVterm
end
```
