@kwdef mutable struct Window
    context::GLFW.Window = GLFW.Window(C_NULL)

    width ::Float64 = 0.0
    height::Float64 = 0.0
    scale ::Float64 = 0.0

    x ::Int = 0.0
    y ::Int = 0.0
    px::Int = 0.0
    py::Int = 0.0
end

@inline function context(it::Window)
    if it.context.handle == C_NULL
        error("application not initialized.")
    end

    return it.context
end

Base.show(io::IO, ::Window) = print(io, "Tela.Window")
Base.bind(it::Window) = GLFW.MakeContextCurrent(context(it))
Base.size(it::Window) = Vec2i(GLFW.GetFramebufferSize(context(it))...)
Base.close(it::Window) = GLFW.SetWindowShouldClose(context(it), true)
Base.isopen(it::Window) = !GLFW.WindowShouldClose(context(it))
Base.resize!(it::Window, size) = GLFW.SetWindowSize(context(it), size[1], size[2])
Base.position(it::Window) = Vec2i(GLFW.GetWindowPos(context(it))...)

Base.wait(::Window) = GLFW.PollEvents()

wsize(it::Window) = GLFW.GetWindowSize(context(it))

"""
    showit(window)

Show `window`.
"""
showit(it::Window) = GLFW.ShowWindow(context(it))

"""
    move!(window, x, y)

Move the `window` to `(x, y)`.
"""
move!(it::Window, x, y) = GLFW.SetWindowPos(context(it), Cint(x), Cint(y))

"""
    vsync!(value)

Set/disable vertical sync.
"""
vsync!(value::Integer) = GLFW.SwapInterval(value)

"""
    scaleof(window) -> Float32

Get the current window's pixel scale.
"""
scaleof(it::Window) = GLFW.GetWindowContentScale(context(it)).xscale

"""
    isvisible(window) -> Bool

Returns `true` if the `window` is currently visible.
"""
isvisible(it::Window)   = Bool(GLFW.GetWindowAttrib(context(it), GLFW.VISIBLE))

"""
    ishovered(window) -> Bool

Returns `true` if the cursor is directly inside the `window`, with no other windows in between.
"""
ishovered(it::Window)   = Bool(GLFW.GetWindowAttrib(context(it), GLFW.HOVERED))

"""
    isfocused(window) -> Bool

Returns `true` if the `window` is currently focused.
"""
isfocused(it::Window)   = Bool(GLFW.GetWindowAttrib(context(it), GLFW.FOCUSED))

"""
    ismaximized(window) -> Bool

Returns `true` if the `window` is currently maximized.
"""
ismaximized(it::Window) = Bool(GLFW.GetWindowAttrib(context(it), GLFW.MAXIMIZED))

"""
    isminimized(window) -> Bool

Returns `true` if the `window` is currently minimized.
"""
isminimized(it::Window) = Bool(GLFW.GetWindowAttrib(context(it), GLFW.ICONIFIED))

"""
    isresizable(window) -> Bool

Returns `true` if the `window` is currently resizable.
"""
isresizable(it::Window) = Bool(GLFW.GetWindowAttrib(context(it), GLFW.RESIZABLE))

"""
    isfloating(window) -> Bool

Returns `true` if the `window` is currently floating.
"""
isfloating(it::Window)  = Bool(GLFW.GetWindowAttrib(context(it), GLFW.FLOATING))

"""
    autofocus!(window, val::Bool)

Enable/disable autofocus when the `window` is shown.
"""
autofocus!(it::Window, val::Bool) = GLFW.SetWindowAttrib(context(it), GLFW.FOCUS_ON_SHOW, val)

"""
    resizable!(window, val::Bool)

Enable/disable `window` resizing.
"""
resizable!(it::Window, val::Bool) = GLFW.SetWindowAttrib(context(it), GLFW.RESIZABLE, val)

"""
    floating!(window, val::Bool)

Enable/disable `window` floating.
"""
floating!(it::Window,  val::Bool) = GLFW.SetWindowAttrib(context(it), GLFW.FLOATING, val)

"""
    swapbuffers(window)

Update the `window`, ie, swapping the front and back buffers.
"""
swapbuffers(it::Window) = GLFW.SwapBuffers(context(it))

function center!(it::Window)
    (; width, height) = GLFW.GetVideoMode(GLFW.GetPrimaryMonitor())
    sz = size(it) ./ scaleof(it)
    pos = Vec2i(width, height) .÷ 2 - sz .÷ 2
    move!(it, pos...)
end

function init(it::Window)
    GLFW.DefaultWindowHints()

    title  = @settings[title] ::String
    width  = @settings[width] ::Int
    height = @settings[height]::Int
    vsync  = @settings[vsync] ::Int

    it.context = GLFW.CreateWindow(width, height, title)
    it.context.handle == C_NULL && error("failed to create a GLFW window.")
    bind(it); center!(it); vsync!(vsync)

    it.width   = width
    it.height  = height
    it.scale   = scaleof(it)
    it.x, it.y = position(it)

    return it
end

function update(it::Window)
    it.px, it.py = it.x, it.y
    it.x, it.y = position(it)

    it.scale = scaleof(it)
    it.width, it.height = size(it)
end

function dispose(it::Window)
    if it.context.handle != C_NULL
        GLFW.DestroyWindow(context(it))
    end
end
