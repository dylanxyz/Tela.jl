using Tela

# Use the setting" macro to set common application settings,
# such as the window title, width, height, etc...

setting"title"  = "[Example] Basic"
setting"width"  = 800
setting"height" = 600

# setup will be called once the application is initialized.
setup(::App) = background(rgb(12))

# update will be called every frame.
function update(::App)
    # Check if a particular mouse button is being pressed
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

# Runs the application.
#
# Basically, this macro will look at the functions you defined and
# add then as callback listeners to specific Tela events, based on
# their name.
#
# So for example, the setup and update functions defined above will
# be added to the setup and update Tela events, respectively.
Tela.@run()
