using Tela

# Tela maintains the state of the mouse as a struct. You can access mouse properties using
# the @mouse macro:
#
#   @mouse -> Returns the whole mouse state.
#   @mouse[prop] -> Returns a specific mouse property.
#
# The mouse properties are:
#
# - button : the mouse button reported in the last mouse button event.
# - scroll : the current horizontal and vertical scroll values as a Vec2f.
# - action : a Symbol indicating the action reported in the last mouse event (:press or :release).
# - x, y   : the current mouse position.
# - px, py : the previous mouse position.
# - dx, dy : the difference between the current and the previous mouse position.

setting"title"  = "[Example] Mouse State"
setting"width"  = 800
setting"height" = 600
setting"vsync"  = true

const scroll = Ref(0.0)
const radius = Ref(10.0)

function update(::App)
    background(rgb(8))

    @layer let i = 0, spacing = 24, y = i * spacing + 10
        fillcolor(rgb(255))
        fontsize(18)
        textalign(:top, :left)

        text("button = $(@mouse[button])", 10, i * spacing + 10); i += 1
        text("action = $(@mouse[action])", 10, i * spacing + 10); i += 1
        text("scroll = $(@mouse[scroll])", 10, i * spacing + 10); i += 1

        i += 1
        text("x = $(@mouse[x])", 10, i * spacing + 10); i += 1
        text("y = $(@mouse[y])", 10, i * spacing + 10); i += 1

        i += 1
        text("dx = $(@mouse[dx])", 10, i * spacing + 10); i += 1
        text("dy = $(@mouse[dy])", 10, i * spacing + 10); i += 1
    end

    @layer begin
        let width = @width, height = @height
            s = clamp(scroll[], 0, 100) / 100
            w = width * s
            h = 10
            x = 0
            y = height - h

            col = hsl(52, 0.85, 0.65), hsl(149, 0.85, 0.65)
            grad = LinearGradient(0, height, width, height, col...)

            fillcolor(grad)
            rect(x, y, w, h, :fill)

            let label = "scroll = $(floor(Int, 100s))%"
                bounds = textbounds(label, 0, 0)
                lw = bounds.xmax - bounds.xmin
                x = clamp(w - lw/2, 0, width - lw)
                fillcolor(rgb(255))
                text(label, x, y - 10)
            end
        end
    end

    @layer let (x, y, px, py, dx, dy) = @mouse[x, y, px, py, dx, dy]
        strokecolor(rgb(128, 96, 81))
        line(0, y, @width, y, :stroke)
        line(x, 0, x, @height, :stroke)

        strokecolor(rgb(96, 128, 81))
        line(0, py, @width, py, :stroke)
        line(px, 0, px, @height, :stroke)

        strokecolor(rgb(128))
        line(px, py, x, y, :stroke)
        line(x, y, x + 5dx, y + 5dy, :stroke)

        fillcolor(rgb(255))
        text("🖱️ $x, $y", x + 10, y - 10)
    end

    @layer begin
        if isdown(mouse"left")
            fillcolor(rgb(244, 32, 32))
        elseif isdown(mouse"right")
            fillcolor(rgb(32, 244, 32))
        elseif isdown(mouse"middle")
            fillcolor(rgb(32, 32, 244))
        end

        circle(@mouse[x], @mouse[y], radius[], :fill)
    end

    if isdown(@mouse)
        radius[] = 32
    end

    # update the scroll
    scroll[] += 2 * @mouse[scroll].y
    # gradually decrease the radius
    radius[] *= 0.8
    radius[] = clamp(radius[], 2, 32)
end

Tela.@run()
