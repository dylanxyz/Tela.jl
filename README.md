# Tela.jl

[Creative Coding](https://en.wikipedia.org/wiki/Creative_coding) with the [Julia](https://julialang.org) programming language.

**Tela.jl** is a Julia package inspired by [Processing](https://processing.org)
and [p5.js](https://p5js.org), designed to be easy to use for programmers and
non programmers (artists, students, etc) to build interactive applications,
visualizations, simulations, games and computer generated art. 

*Warning: this project is in a very early stage and under development.*

## Installation

Tela is a &nbsp;
    <a href="https://julialang.org">
        <img src="https://raw.githubusercontent.com/JuliaLang/julia-logo-graphics/master/images/julia.ico" width="16em">
        Julia Language
    </a>
    &nbsp; package. To install Tela,
    <a href="https://docs.julialang.org/en/v1/manual/getting-started/">open
    Julia's interactive session (known as REPL)</a> and press <kbd>]</kbd> key in the REPL to use the package mode, then type the following command:
</p>

```shell
pkg> add https://github.com/dylanxyz/Tela.jl
```

> Note that Tela is not yet at the public registry,
> installation is done directly from this repo.

## Quick Example

```julia
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
# add them as callback listeners to specific Tela events, based on
# their name.
#
# So for example, the setup and update functions defined above will
# be added to the setup and update Tela events, respectively.
Tela.@run()
```

## Documentation

*In progress...*

## License

**Tela.jl** is licensed under the [MIT License](./LICENSE).

Additional license for assets:

- Roboto is licensed under the [Apache License](./assets/fonts/Roboto/LICENSE.txt)
- Noto Emoji licensed under [SIL Open Font License, Version 1.1](./assets/fonts/NotoEmoji/OFL.txt)