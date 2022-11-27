using Tela

setting"title"  = "Basic Example"
setting"width"  = 800
setting"height" = 600

const radius = Ref(32.0)

function update(::App)
    background(rgb(12))
    fillcolor(rgb(255))
    circle(@mouse[x], @mouse[y], radius[], :fill)

    if isdown(mouse"left")
        radius[] += 512 * @frametime
    elseif isdown(mouse"right")
        radius[] -= 512 * @frametime
    elseif isdown(mouse"middle")
        radius[] = 32
    end
end

Tela.@run()
