using Tela

# Tela maintains internally a Input struct that holds common input properties, such as the key that is
# currently being pressed (or that was released), text that the user typed, etc...
# You can access those properties using the @input macro:
#
#   @input -> Returns the Input struct.
#   @input[prop] -> Returns a specific input property.
#
# The input properties are:
#
# - key    : the keyboard key reported in the last key event.
# - text   : the character the user typed after pressing a key.
# - action : a Symbol indicating the action reported in the last key event (:press or :release).
# - drop   : the paths that the user dropped inside the window.

setting"title"  = "[Example] Input State"
setting"width"  = 800
setting"height" = 600
setting"vsync"  = true

function update(::App)
    background(rgb(8))

    info = """
    key = $(@input[key])
    text = $(@input[text])
    action = $(@input[action])
    dropped = $(@input[drop])
    """

    spacing = 32

    fontsize(22)
    breaklines(info, 800) do row, i
        text(row.text, 10, spacing * i)
    end
end

Tela.@run()
