using Tela

setting"title"  = "[Example] Input Events"
setting"width"  = 800
setting"height" = 600

setup(::App) = background(rgb(12))

function onkeydown(input::Input)
    @info "A key was pressed!" key=input.key
end

function onkeyup(input::Input)
    @info "A key was released!" key=input.key
end

function onkeypress(input::Input)
    @info "A key is being pressed down!" key=input.key
end

function oninput(input::Input)
    @info "A character was typed!" text=input.text
end

function ondrop(input::Input)
    @info "Some paths were dropped!" paths=input.drop
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
