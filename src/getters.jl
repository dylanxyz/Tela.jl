"""
    @settings() -> Settings
    @settings[key] -> Any

Returns the application `settings`.

`settings` is a global dictionary mapping a setting (a `Symbol`) to its value.

Without arguments, this macro will return the whole dictionary.

```julia
julia> @settings
3-element Tela.Settings
  :title  │ "My App"
  :width  │ 400
  :height │ 600
  ⋮
```

You can access individual settings using the `getindex` syntax. For example:

```julia
julia> @settings[title]
"My App"

julia> @settings[width]
400
```

Accessing multiple settings at once is allowed:

```julia
julia> @settings[width, height]
(400, 600)

julia> @settings[title, width, height]
("My App", 400, 600)
```

---

**What if i want to access a setting where the key is the value of a variable?**

Use the `\$` expression:

```julia
julia> key_a, key_b = :title, :width
:title

julia> @settings[\$key_a]
"My App"

julia> @settings[\$key_a, \$key_b]
("My App", 400)
```
"""
macro settings() :(Settings()) end
macro settings(i) getter(:(@settings), i, :ref) end

"""
    @events() -> Dictionary{Symbol, Observable}
    @events[key] -> Observable

Returns the application `events`.

`events` is a global dictionary mapping an event (a `Symbol`) to an `Observable`.

Without arguments, this macro will return the whole dictionary.

```julia
julia> @events
29-element Dictionaries.Dictionary{Symbol, Observables.Observable}
  :configure │ Observable(Tela.App)
  :setup     │ Observable(Tela.App)
  :dispose   │ Observable(Tela.App)
  ⋮
```

You can access individual events using the `getindex` syntax. For example:

```julia
julia> @events[setup]
Observable(Tela.App)

julia> @events[onmousedown]
Observable(Tela.Mouse)
```

Accessing multiple events at once is allowed:

```julia
julia> @events[onkeyup, ondrag]
(Observable(Tela.Input), Observable(Tela.Mouse))

julia> @events[onkeyup, ondrag, ondrop]
(Observable(Tela.Input), Observable(Tela.Mouse), Observable(Tela.Input))
```

---

**What if i want to access an event where the key is the value of a variable?**

Use the `\$` expression:

```julia
julia> key_a, key_b = :onresize, :configure
(:onresize, :configure)

julia> @events[\$key_a]
Observable(Tela.Window)

julia> @events[\$key_a, \$key_b]
(Observable(Tela.Window), Observable(Tela.App))
```
"""
macro events() :(Events) end
macro events(i) getter(:(@events), i, :ref) end

"""
    @app() -> App
    @app[prop] -> Any

Returns the current Tela `application`.

The `application` is a `struct` holding the [`Clock`](@ref),
[`Mouse`](@ref), [`Input`](@ref) and [`Window`](@ref) states.

```julia
julia> @app
Tela.App
```

You can access indivual `application` properties using the `getindex` syntax:

```julia
julia> @app[clock]
Clock(t = 0 s, Δt = 0.0 ms, fps = Inf frames/s)

julia> @app[mouse]
Tela.Mouse
```

Accessing multiple properties at once is allowed:

```julia
julia> @app[window, mouse]
(Tela.Window, Tela.Mouse)

julia> @app[input, mouse, window]
(Tela.Input, Tela.Mouse, Tela.Window)
```
"""
macro app() :(Application) end
macro app(i) getter(:(@app), i) end

"""
    @window() -> Window
    @window[prop] -> Any

Returns the current application's `window` state.

```julia
julia>@window
Tela.Window
```

You can access individual properties using the `getindex` syntax:

```julia
julia> @window[width]
400.0

julia> @window[height]
400.0
```

Accessing multiple properties at once is allowed:

```julia
julia> @window[x, y]
(10, 10)

julia> @window[scale, x, y]
(1.0, 10, 100)
```
"""
macro window() :(Application.window) end
macro window(i) getter(:(@window), i) end

"""
    @mouse() -> Mouse
    @mouse[prop] -> Any

Returns the current application's `mouse` state.

```julia
julia>@mouse
Tela.Mouse
```

You can access individual properties using the `getindex` syntax:

```julia
julia> @mouse[dragging]
false

julia> @mouse[button]
MouseButton(Unknown)
```

Accessing multiple properties at once is allowed:

```julia
julia> @mouse[x, y]
(0.0, 0.0)

julia> @mouse[x, y, scroll]
(0.0, 0.0, [0.0, 0.0])
```
"""
macro mouse() :(Application.mouse) end
macro mouse(i) getter(:(@mouse), i) end

"""
    @input() -> Input
    @input[prop] -> Any

Returns the current application's `input` state.

```julia
julia>@input
Tela.Input
```

You can access individual properties using the `getindex` syntax:

```julia
julia> @input[key]
Key(UNKNOWN::-1)

julia> @input[text]
""
```

Accessing multiple properties at once is allowed:

```julia
julia> @input[key, drop]
(Key(UNKNOWN::-1), String[])

julia> @input[key, drop, text]
(Key(UNKNOWN::-1), String[], "")
```
"""
macro input() :(Application.input) end
macro input(i) getter(:(@input), i) end

"""
    @canvas() -> NanoVG.Canvas
    @canvas[prop] -> Any

Returns the current application `canvas`.
"""
macro canvas() :(Application.canvas) end
macro canvas(i) getter(:(@canvas), i) end

# * ------------------------------------------------------------------------------- * #
# * -----------------------------| Common Properties |----------------------------- * #
# * ------------------------------------------------------------------------------- * #

"""
    @width() -> Float64

Returns the window `width` in pixels.
"""
macro width() :(@window[width]) end

"""
    @height() -> Float64

Returns the window `height` in pixels.
"""
macro height() :(@window[height]) end

"""
    @seconds() -> Float64

Returns the time (in seconds) since the start of the application.
"""
macro seconds() :(@app[clock].elapsed) end

"""
    @frametime() -> Float64

Returns the time (in seconds) since the last frame drawn.
"""
macro frametime() :(@app[clock].interval) end

"""
    @framerat() -> Float64

Returns the number of frames that were drawn since the last 1 second.
"""
macro framerate() :(framerate(@app[clock])) end
