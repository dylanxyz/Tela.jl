using Tela

setting"title"  = "[Example] Mouse Events"
setting"width"  = 800
setting"height" = 600

setup(::App) = background(rgb(12))

function onmousedown(mouse::Mouse)
    @info "A mouse button was pressed down!" button=mouse.button
end

function onmouseup(mouse::Mouse)
    @info "A mouse button was released!" button=mouse.button
end

function onmousemove(mouse::Mouse)
    pos = mouse.x, mouse.y
    @info "Cursor moved!" pos
end

function ondrag(mouse::Mouse)
    pos = mouse.x, mouse.y
    @info "Cursor dragged!" pos
end

function onscroll(mouse::Mouse)
    @info "Scrolling with the mouse!" scroll=mouse.scroll
end

function update(::App)
    if isdown(mouse"left")
        hue = 360 * (cos(π/12 * @seconds) + 1)
        fillcolor(hsl(hue, 0.75, 0.65))
        circle(@mouse[x], @mouse[y], 32, :fill)
    end

    isdown(mouse"right") && background(rgb(12))

    # Top header
    fillcolor(rgb(10))
    rect(0, 0, @width, 30, :fill)

    fillcolor(rgb(244))
    textalign(:top, :left)
    fontface("sans")
    text("Hold Mouse Left 🖱️ to draw | Press Mouse Right 🖱️ to clear", 10, 10)
end

Tela.@run()
