"""
A dictionary containing the current application settings.
"""
struct Settings <: AbstractDictionary{Symbol, Any} end

Base.keys(::Settings) = keys(_Settings)
Base.getindex(::Settings, i::Symbol) = last(_Settings[i])
Base.isassigned(::Settings, i::Symbol) = isassigned(_Settings, i)

Base.insert!(::Settings, i, v) = addsetting(i, v)
Base.delete!(::Settings, i) = rmsetting(i)

Dictionaries.issetable(::Settings) = true
Dictionaries.isinsertable(::Settings) = true

function Base.setindex!(::Settings, val, i::Symbol)
    i ∉ keys(_Settings) && error("trying to set non existent setting: $i")
    T = first(_Settings[i])

    if !applicable(convert, T, val)
        S = typeof(val)
        error("at setting '$i': expected a value convertible to $T, but a value of type $S was used.")
    end

    _Settings[i] = Pair(T, convert(T, val))
    @fire onsetting(i)

    return Settings()
end

const DefaultSettings = (;
    title        = "My App",
    width        = 400,
    height       = 400,
    vsync        = 0,
    framerate    = Inf,
    resizable    = true,
    antialiasing = true,
)

const _Settings = dictionary(k => Pair(typeof(v), v) for (k, v) in pairs(DefaultSettings))

"""
    addsetting(name, val)

Registers a new `setting` identified by `name` with initial value `val`.
"""
function addsetting(name::Symbol, val)
    insert!(_Settings, name, Pair(typeof(val), val))
    @fire on_newsetting(name)
    return Settings()
end

function rmsetting(name::Symbol)
    delete!(_Settings, name)
    @fire on_rmsetting(name)
    return Settings()
end

macro setting_str(s)
    sym = QuoteNode(Symbol(s))
    :(Settings()[$sym])
end

"""
    @newsetting name = val

Registers a new setting identified by `name` and initial value `val`.
"""
macro newsetting(expr)
    if isexpr(expr, :(=))
        name = QuoteNode(first(expr.args))
        val = esc(last(expr.args))
        return :(addsetting($name, $val))
    end

    error("invalid usage of @newsetting: expected assignment expression.")
end
