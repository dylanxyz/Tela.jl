module Tela

using Dictionaries
using GLFW
using ModernGL
using Observables
using Reexport

@reexport using NanoVG

import NanoVG: Canvas

# TODO: move this to NanoVG
Canvas() = Canvas(convert(Ptr{NanoVG.LibNanoVG.NVGLUframebuffer}, C_NULL), 0, 0, 0)

using Base: @kwdef
using Base.Meta

import Base: ==, +, -, *, /

# * ----- Macros ----- * #
export @app
export @asset_str
export @assets
export @assets_str
export @canvas
export @events
export @framerate
export @frametime
export @height
export @input
export @input_str
export @key_str
export @mouse
export @mouse_str
export @seconds
export @setting_str
export @settings
export @width
export @window

# * ----- Types ----- * #
export App
export Input
export Key
export Mouse
export MouseButton
export Window

# * ----- Methods ----- * #

export asset
export autofocus!
export center!
export floating!
export isdown
export isfloating
export isfocused
export ishovered
export ismaximized
export isminimized
export isresizable
export isup
export isvisible
export move!
export resizable!
export vsync!

abstract type State end

Base.show(io::IO, ::T) where {T <: State} = print(io, "Tela.", nameof(T))

"""
    isup(input::Input) -> Bool
    isup(mouse::Mouse) -> Bool
    isup(key::Key) -> Bool
    isup(button::MouseButton) -> Bool

Checks if no *mouse* button or key is being pressed.

Additionally, you can check if a specific `key` or mouse `button` is *up*.

See also: [`isdown`](@ref).
"""
function isup end

"""
    isdown(input::Input) -> Bool
    isdown(mouse::Mouse) -> Bool
    isdown(key::Key) -> Bool
    isdown(button::MouseButton) -> Bool

Checks if any *mouse* button or key is being pressed.

Additionally, you can check if a specific `key` or mouse `button` is *down*.

See also: [`isup`](@ref).
"""
function isdown end

include("getters.jl")
include("utils.jl")
include("vec.jl")
include("settings.jl")
include("assets.jl")
include("window.jl")
include("mouse.jl")
include("input.jl")
include("app.jl")
include("events.jl")

function use(mod::Module)
    for name in keys(@events)
        if isdefined(mod, name)
            f = getproperty(mod, name)
            if f isa Function
                on(f, @events[$name])
            end
        end
    end
end

function run(mod::Module)
    use(mod)
    run();
end

function run()
    try
        init(@app)
        start(@app)
    finally
        dispose(@app);
    end
end

end # module
