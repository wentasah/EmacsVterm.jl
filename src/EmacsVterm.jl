module EmacsVterm

import REPL
import Base64
import Markdown

"""
    Options

Structure containing the package global options, accessible through
`EmacsVterm.options`.

# Fields
- `markdown::Bool`: whether to send Markdown to Emacs for displaying in `*julia-doc*` buffer (default: `true`).
- `image::Bool`: whether to send images to Emacs for displaying in `*julia-img*` buffer (default: `false`)
"""
Base.@kwdef mutable struct Options
    markdown::Bool = true
    image::Bool = false
end

struct Display <: AbstractDisplay
    io::IO
end

EMACS = nothing

@doc (@doc Options)
const options = Options()

const user = get(ENV, "USER", "")
vterm_cmd(str) = "\e]$str\e\\"
prompt_suffix() = vterm_cmd("51;A$(user)@$(gethostname()):$(pwd())")
eval_elisp(elisp) = vterm_cmd("51;E$(elisp)")

# Show rendered Markdown in Emacs *julia-doc* buffer.
function Base.display(d::Display, md::Markdown.MD)
    if options.markdown
        write(d.io, eval_elisp("julia-repl--show documentation text/html \"$(md |> Markdown.html |> Base64.base64encode)\""))
    else
        throw(MethodError(display, (d, md)))
    end
    return nothing
end

const IMAGE_MIMES = MIME[
    MIME"image/svg+xml"(),
    MIME"image/png"(),
    MIME"image/jpg"(),
    MIME"image/jpeg"(),
]

function Base.display(d::Display, m::MIME, x)
    if options.image && m in IMAGE_MIMES
        base64 = (m == MIME"image/svg+xml"()) ?
            Base64.base64encode(repr("image/svg+xml", x)) :
            Base64.stringmime(m, x)
        write(d.io, eval_elisp("julia-repl--show image $(string(m)) \"$(base64)\""))
    else
        throw(MethodError(display, (d, m, x)))
    end
    return nothing
end

function Base.display(d::Display, x)
    for mime in IMAGE_MIMES
        if showable(mime, x)
            return display(d, mime, x)
        end
    end
   throw(MethodError(Base.display, (d, x)))
end

"""
    display_on()

Enable multimedia Emacs display.
"""
function display_on()
    if EMACS ∉ Base.Multimedia.displays
        pushdisplay(EMACS)
    end
    return nothing
end

"""
    display_off()

Disable multimedia Emacs display.
"""
function display_off()
    popdisplay(EMACS)
    return nothing
end

function __init__()
    if !(isinteractive() && isdefined(Base, :active_repl))
        return
    end
    begin
        if get(ENV, "INSIDE_EMACS", "") == "vterm"
            @info "Emacs vterm detected"
            repl = Base.active_repl

            if !isdefined(repl,:interface)
                repl.interface = REPL.setup_interface(repl)
            end

            suffix = repl.interface.modes[1].prompt_suffix
            repl.interface.modes[1].prompt_suffix = function ()
                ((isa(suffix,Function) ? suffix() : suffix) * prompt_suffix())
            end

            global EMACS = Display(stdout)
            display_on()
        end
    end
end

end
