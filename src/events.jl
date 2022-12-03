const Events = dictionary((
    # Life Cycle Events
    :configure     => Observable(@app),
    :setup         => Observable(@app),
    :dispose       => Observable(@app),
    # Update Events
    :before_update => Observable(@app),
    :update        => Observable(@app),
    :after_update  => Observable(@app),
    # Window Events
    :onresize      => Observable(@window),
    :onmove        => Observable(@window),
    :onclose       => Observable(@window),
    :onfocus       => Observable(@window),
    :onblur        => Observable(@window),
    :onmaximize    => Observable(@window),
    :onminimize    => Observable(@window),
    :onrestore     => Observable(@window),
    # Mouse Events
    :onmouseup     => Observable(@mouse),
    :onmousedown   => Observable(@mouse),
    :onmousemove   => Observable(@mouse),
    :ondrag        => Observable(@mouse),
    :onscroll      => Observable(@mouse),
    # Input Events
    :onkeypress    => Observable(@input),
    :onkeydown     => Observable(@input),
    :onkeyup       => Observable(@input),
    :oninput       => Observable(@input),
    :ondrop        => Observable(@input),
    # Advanced events
    :onsetting     => Observable{Symbol}(),
    :on_newsetting => Observable{Symbol}(),
    :on_remsetting => Observable{Symbol}(),
))

function fire(event::Symbol)
    event ∉ keys(Events) && error("trying to dispatch non existent event: $event")
    notify(Events[event])
end

function fire(event::Symbol, @nospecialize(data))
    event ∉ keys(Events) && error("trying to dispatch non existent event: $event")
    setindex!(Events[event], data)
end

function newevent(name::Symbol, event::Observable)
    insert!(Events, name, event)
end

function remevent(name::Symbol)
    delete!(Events, name)
end

# * ---------------------------------------------------------------------------- * #
# * -----------------------------| Event Handlers |----------------------------- * #
# * ---------------------------------------------------------------------------- * #

# * -----------------------------| Window Handlers |----------------------------- * #

onmaximize(@nospecialize(f::Function)) = on(f, @events[onmaximize])
onminimize(@nospecialize(f::Function)) = on(f, @events[onminimize])
onrestore(@nospecialize(f::Function)) = on(f, @events[onrestore])
onresize(@nospecialize(f::Function)) = on(f, @events[onresize])
onclose(@nospecialize(f::Function)) = on(f, @events[onclose])
onfocus(@nospecialize(f::Function)) = on(f, @events[onfocus])
onblur(@nospecialize(f::Function)) = on(f, @events[onblur])
onmove(@nospecialize(f::Function)) = on(f, @events[onmove])

function onresize(::Any, width, height)
    let dpr = scaleof(@window)
        # @window[scale]  = dpr
        # @window[width]  = dpr * width
        # @window[height] = dpr * height

        # resize the canvas
        if width > 0 && height > 0
            fw, fh = dpr .* (width, height)
            img = pattern(@app[canvas], 0, 0)

            @app[canvas] = Canvas(fw, fh)

            NanoVG.frame(@app[canvas], dpr)
            fillcolor(img)
            rect(0, 0, fw, fh, :fill)
            NanoVG.render()
        end
    end

    @fire onresize
end

function onmove(::Any, x,  y)
    # @window[px, py] = @window[x, y]
    # @window[x, y] = x, y

    @fire onmove
end

function onmaximize(::Any, maximized)
    if Bool(maximized)
        @fire onmaximize
    else
        @fire onrestore
    end
end

function onminimize(::Any, minimized)
    if Bool(minimized)
        @fire onminimize
    else
        @fire onrestore
    end
end

function onfocus(::Any, focused)
    if Bool(focused)
        @fire onfocus
    else
        @fire onblur
    end
end

function onclose(::Any)
    @fire onclose
end

# * -----------------------------| Mouse Handlers |----------------------------- * #

onmousedown(@nospecialize(f::Function)) = on(f, @events[onmousedown])
onmousemove(@nospecialize(f::Function)) = on(f, @events[onmousemove])
onmouseup(@nospecialize(f::Function)) = on(f, @events[onmouseup])
onscroll(@nospecialize(f::Function)) = on(f, @events[onscroll])
ondrag(@nospecialize(f::Function)) = on(f, @events[ondrag])

function onmousepress(::Any, button, action, mods)
    @mouse[button] = MouseButton(button)
    @mouse[mods] = mods

    if action == GLFW.PRESS
        @mouse[action] = :press
        @mouse[dragging] = true
        @fire onmousedown
    elseif action == GLFW.RELEASE
        @mouse[action] = :release
        @mouse[dragging] = false
        @fire onmouseup
    end
end

function onmousemove(::Any, x, y)
    # @mouse[px, py] = @mouse[x, y]
    # @mouse[x, y] = (x, y) .* @window[scale]
    # @mouse[dx, dy] = @mouse[x, y] .- @mouse[px, py]
    @fire onmousemove

    if @mouse[dragging]
        @fire ondrag
    end
end

function onscroll(::Any, x, y)
    @mouse[scroll] = Vec2f(x, y)
    @fire onscroll
end

# * -----------------------------| Input Handlers |----------------------------- * #

onkeypress(@nospecialize(f::Function)) = on(f, @events[onkeypress])
onkeydown(@nospecialize(f::Function)) = on(f, @events[onkeydown])
onkeyup(@nospecialize(f::Function)) = on(f, @events[onkeyup])
oninput(@nospecialize(f::Function)) = on(f, @events[oninput])
ondrop(@nospecialize(f::Function)) = on(f, @events[ondrop])

function onkeypress(::Any, key, code, action, mods)
    @input[key] = Key(key, code)
    @input[mods] = mods

    if action == GLFW.PRESS
        @input[action] = :press
        @fire onkeypress onkeydown
    elseif action == GLFW.RELEASE
        @input[action] = :release
        @fire onkeyup
    else
        @fire onkeypress
    end
end

function oninput(::Any, code)
    @input[text] = string(Char(code))
    @fire oninput
end

function ondrop(::Any, paths)
    @input[drop] = paths
    @fire ondrop
end
