struct Key
    id::Cint
    code::Cint
end

Key() = Key(-1, -1)
Key(key::GLFW.Key) = Key(Cint(key), Cint(key) == -1 ? -1 : keycode(key))
Key(key::GLFW.Key, code) = Key(Cint(key), code)

function Base.nameof(key::Key)
    names = Base.Enums.namemap(GLFW.Key)
    name = get(names, key.id, :KEY_UNKNOWN)
    return Symbol(string(name)[5:end])
end

function Base.show(io::IO, key::Key)
    name, code = nameof(key), key.code
    print(io, "Key($name::$code)")
end

@kwdef mutable struct Input <: State
    key::Key = Key()
    mods::Cint = 0
    action::Symbol = :none
    text::String = ""
    drop::Vector{String} = String[]
end

isup(key::Key) = GLFW.GetKey(context(@window), key.id) == Cint(GLFW.RELEASE)
isdown(key::Key) = GLFW.GetKey(context(@window), key.id) == Cint(GLFW.PRESS)

isup(input::Input) = isup(input.key)
isdown(input::Input) = isdown(input.key)

"""
    key"name" -> Key

Returns a keyboard [`Key`](@ref) object.

See [GLFW: Keyboard keys](https://www.glfw.org/docs/latest/group__keys.html)
to see which keys are defined.

*Important: do not use the `GLFW_KEY_` prefix.*

**Examples:**

```julia
julia> key"A"
Key(A::30)

julia> key"HOME"
Key(HOME::327)

julia> key"SPACE"
Key(SPACE::57)
```
"""
macro key_str(s)
    sym = Symbol(:KEY_, uppercase(s))
    isdefined(GLFW, sym) || error("invalid key: " * repr(s))
    return :(Key(GLFW.$sym))
end
