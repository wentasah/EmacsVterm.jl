module EmacsVterm

import REPL
import Base64
import Markdown

struct Display <: AbstractDisplay
    io::IO
end
Display() = Display(stdout)

const user = get(ENV, "USER", "")
vterm_cmd(str) = "\e]$str\e\\"
prompt_suffix() = vterm_cmd("51;A$(user)@$(gethostname()):$(pwd())")
eval_elisp(elisp) = vterm_cmd("51;E$(elisp)")

# Show rendered Markdown in Emacs *julia-doc* buffer.
function Base.display(d::Display, md::Markdown.MD)
    write(d.io, eval_elisp("julia-repl--show documentation text/html \"$(md |> Markdown.html |> Base64.base64encode)\""))
end

const IMAGE_MIMES = MIME[
    MIME"image/png"(),
    MIME"image/jpg"(),
    MIME"image/jpeg"(),
]

function Base.display(d::Display, m::MIME, x)
    if m in IMAGE_MIMES
        write(d.io, eval_elisp("julia-repl--show image $(string(m)) \"$(Base64.stringmime(m, x))\""))
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

            pushdisplay(Display())
        end
    end
end

end
