struct MouseButton
    id::Cint
end

MouseButton() = MouseButton(-1)
MouseButton(button::GLFW.MouseButton) = MouseButton(Cint(button))

==(a::MouseButton, b::MouseButton) = a.id == b.id
==(a::MouseButton, b::GLFW.MouseButton) = a.id == Cint(b)
==(a::GLFW.MouseButton, b::MouseButton) = Cint(a) == b.id

function Base.nameof(button::MouseButton)
    button == GLFW.MOUSE_BUTTON_1 ? :Left :
    button == GLFW.MOUSE_BUTTON_2 ? :Right :
    button == GLFW.MOUSE_BUTTON_3 ? :Middle :
    button.id + 1 in 4:8 ? Symbol(button.id + 1) :
    #= else =# :Unknown
end

function Base.show(io::IO, button::MouseButton)
    name = nameof(button)
    print(io, "MouseButton($name)")
end

@kwdef mutable struct Mouse <: State
    button::MouseButton = MouseButton()
    scroll::Vec2f = Vec2f(0, 0)
    dragging::Bool = false

    mods::Cint = 0
    action::Symbol = :none

    x::Float64 = 0.0
    y::Float64 = 0.0

    px::Float64 = 0.0
    py::Float64 = 0.0

    dx::Float64 = 0.0
    dy::Float64 = 0.0
end

Base.position(::Mouse) = GLFW.GetCursorPos(context(@window))
move!(::Mouse, x, y) = GLFW.SetCursorPos(context(@window), x, y)

function isup(button::MouseButton)
    button.id == -1 && return false
    GLFW.GetMouseButton(context(@window), button.id) == Cint(GLFW.RELEASE)
end

function isdown(button::MouseButton)
    button.id == -1 && return false
    GLFW.GetMouseButton(context(@window), button.id) == Cint(GLFW.PRESS)
end

isup(mouse::Mouse) = isup(mouse.button)
isdown(mouse::Mouse) = isdown(mouse.button)

"""
    mouse"button" -> MouseButton

Returns a [`MouseButton`](@ref) object.

`button` can be one of:

* `left` or `1` - The left mouse button;
* `right` or `2` - The right mouse button;
* `middle` or `3` - The middle mouse button;
* a number between `4` and `8`

**Examples:**

```julia
julia> mouse"left"
MouseButton(Left)

julia> mouse"right"
MouseButton(Right)

julia> mouse"3"
MouseButton(Middle)

julia> mouse"4"
MouseButton(4)
```
"""
macro mouse_str(s)
    sym = Symbol(:MOUSE_BUTTON_, uppercase(s))
    isdefined(GLFW, sym) || error("invalid mouse button: " * repr(s))
    return :(MouseButton(GLFW.$sym))
end

function update(mouse::Mouse)
    mouse.scroll = Vec2f(0, 0)
end
