@kwdef mutable struct App <: State
    window::Window = Window()
    input ::Input  = Input()
    mouse ::Mouse  = Mouse()
    clock ::Clock  = Clock()
end

const Application = App()

function init(app::App)
    @fire configure
    GLFW.WindowHint(GLFW.RESIZABLE, @settings[resizable]::Bool)

    init(app.window)

    let context = context(app.window)
        # Window Handlers
        GLFW.SetWindowCloseCallback(context, onclose)
        GLFW.SetWindowSizeCallback(context, onresize)
        GLFW.SetWindowPosCallback(context, onmove)
        GLFW.SetWindowMaximizeCallback(context, onmaximize)
        GLFW.SetWindowIconifyCallback(context, onminimize)
        GLFW.SetWindowFocusCallback(context, onfocus)
        # Mouse Handlers
        GLFW.SetCursorPosCallback(context, onmousemove)
        GLFW.SetMouseButtonCallback(context, onmousepress)
        GLFW.SetScrollCallback(context, onscroll)
        # Input Handlers
        GLFW.SetKeyCallback(context, onkeypress)
        GLFW.SetCharCallback(context, oninput)
        GLFW.SetDropCallback(context, ondrop)
    end

    antialiasing = @settings[antialiasing]::Bool
    NanoVG.create(NanoVG.GL3; antialiasing)

    loadfonts()
    @fire setup
end

frametime() = inv(@settings[framerate]::Float64)

function start(app::App)
    clock = Clock()

    while isopen(app.window)
        wait(app.window)
        update(clock)

        if elapsed(app.clock) >= frametime()
            reset(clock)
            update(app.clock)
            @fire before_update

            let window = app.window, dpr = scaleof(window)
                glViewport(0, 0, size(window)...)
                NanoVG.frame(wsize(window)..., dpr)
                @fire update
                NanoVG.render()
            end

            @fire after_update
            update(app.window)
        end
    end
end

function dispose(app::App)
    @fire dispose

    if isassigned(NanoVG.CONTEXT) && NanoVG.@vg() != C_NULL
        NanoVG.dispose()
    end

    dispose(app.window)

    for event in keys(@events)
        # remove all event handlers
        empty!(Observables.listeners(@events[$event]))
    end
end
