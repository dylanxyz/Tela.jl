using Tela

setting"title"  = "Basic Example"
setting"width"  = 800
setting"height" = 600
setting"vsync"  = true

function configure(::App)
    @info "Configuring..."
end

function setup(::App)
    @info "Starting..."
    background(rgb(12))
end

function update(::App)
    if isdown(mouse"left")
        hue = 360 * (cos(π/12 * @seconds) + 1)
        fillcolor(hsl(hue, 0.75, 0.65))
        circle(@mouse[x], @mouse[y], 32, :fill)
    end

    isdown(mouse"right") && background(rgb(12))
end

function dispose(::App)
    @info "Bye..."
end

Tela.@run()
