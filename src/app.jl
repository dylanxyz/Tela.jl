@kwdef mutable struct App <: State
    window::Window = Window()
    input ::Input  = Input()
    mouse ::Mouse  = Mouse()
    clock ::Clock  = Clock()
    canvas::Canvas = Canvas()
end

const Application = App()

function init(app::App)
    @fire configure
    GLFW.WindowHint(GLFW.RESIZABLE, @settings[resizable]::Bool)

    init(app.window)

    if setting"addcallbacks"::Bool
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
    end

    antialiasing = @settings[antialiasing]::Bool
    NanoVG.create(NanoVG.GL3; antialiasing)

    app.canvas = Canvas(@window[width, height]...)
    bind(app.canvas)

    loadfonts()
    @fire setup
end

frametime() = inv(@settings[framerate]::Float64)

function start(app::App)
    clock = Clock()

    while isopen(app.window)
        wait(app.window)
        update(clock)

        if elapsed(clock) >= frametime()
            reset(clock)
            update(app.clock)
            @fire before_update

            let window = app.window, dpr = scaleof(window)
                fw, fh = size(window)
                ww, wh = wsize(window)

                NanoVG.frame(app.canvas, dpr)
                @fire update
                NanoVG.render(app.canvas)

                glViewport(0, 0, fw, fh)
                NanoVG.frame(ww, wh, dpr)
                fillcolor(pattern(app.canvas, 0, 0))
                rect(0, 0, fw, fh, :fill)
                NanoVG.render()
            end

            @fire after_update
            swapbuffers(window)
        end

        update(app.window)
        update(app.mouse)
    end
end

function dispose(app::App)
    @fire dispose

    if app.canvas.fbo != C_NULL
        NanoVG.delete(app.canvas)
    end

    if isassigned(NanoVG.CONTEXT) && NanoVG.@vg() != C_NULL
        NanoVG.dispose()
    end

    dispose(app.window)

    for event in keys(@events)
        # remove all event handlers
        empty!(Observables.listeners(@events[$event]))
    end
end
