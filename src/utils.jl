"""
    @fire event
    @fire event(data)

Fires `event`, optionally updating it with `data`.

**Example:**

```julia
julia> using Tela: on, @event, @events, @fire

julia> @event myevent = 0;

julia> on(@events[myevent]) do x
           @info "myevent was fired!" data=x
       end
ObserverFunction defined at REPL[5]:2 operating on Observable(0)

julia> @fire myevent;
┌ Info: myevent was fired!
└   data = 0

julia> @fire myevent(5);
┌ Info: myevent was fired!
└   data = 5
```
"""
macro fire(expr...)
    block = Expr(:block)

    for ex in expr
        # @fire event(arg)
        if isexpr(ex, :call)
            event, args... = ex.args
            event = QuoteNode(event)
            if isempty(args)
                push!(block.args, :(fire($event)))
            else
                data = esc(first(args))
                push!(block.args, :(fire($event, $data)))
            end
        # @fire event
        elseif ex isa Symbol
            event = QuoteNode(ex)
            push!(block.args, :(fire($event)))
        end
    end

    return block
end

"""
    @event name = val
    @event name{type}

Registers a new event identified by `name`.

The event `type` must be provided if the initial value `val` is not passed.

**Example:**

```julia
julia> using Tela: on, @event, @events, @fire

julia> @event myevent = 0;

julia> on(@events[myevent]) do x
           @info "myevent was fired!" data=x
       end
ObserverFunction defined at REPL[5]:2 operating on Observable(0)

julia> @fire myevent;
┌ Info: myevent was fired!
└   data = 0

julia> @fire myevent(5);
┌ Info: myevent was fired!
└   data = 5
```
"""
macro event(expr)
    if isexpr(expr, :(=))
        name = QuoteNode(first(expr.args))
        value = esc(last(expr.args))
        return :(newevent($name, Observable($value)))
    elseif isexpr(expr, :curly)
        name = QuoteNode(first(expr.args))
        T = esc(last(expr.args))
        return :(newevent($name, Observable{$T}()))
    else
        error("invalid usage of @event")
    end
end

macro use() :(use($__module__)) end
macro run() :(run($__module__)) end

@kwdef mutable struct Clock
    elapsed::Float64 = 0.0
    interval::Float64 = 0.0
    then::Float64 = -1.0
end

elapsed(clock::Clock) = clock.elapsed
framerate(clock::Clock) = inv(clock.interval)

function update(clock::Clock)
    if clock.then < 0
        clock.then = time_ns()
    end

    now = time_ns()
    clock.interval = 1e-9 * (now - clock.then)
    clock.elapsed += clock.interval
    clock.then = now
    return clock
end

function Base.reset(clock::Clock)
    clock.elapsed = 0.0
end

function Base.show(io::IO, clock::Clock)
    t = floor(Int, clock.elapsed)
    dt = round(1000 * clock.interval, digits=2)
    fps = trunc(framerate(clock))
    print(io, "Clock(t = $t s, Δt = $dt ms, fps = $fps frames/s)")
end

keycode(key::GLFW.Key) = @ccall GLFW.libglfw.glfwGetKeyScancode(key::Cint)::Cint

function getter(object, props, type = :(.))
    props == [] && return object

    isexpr(props, :vect) || error("expected vect expression, got: " * repr(props))

    let res = Expr(:tuple)
        for x in props.args
            if !isa(x, Expr)
                x = QuoteNode(x)
            elseif isexpr(x, :$)
                x = esc(first(x.args))
            else
                error("use '\$' to interpolate an expression.")
            end

            push!(res.args, Expr(type, object, x))
        end

        return res.args |> isone ∘ length ? first(res.args) : res
    end
end
