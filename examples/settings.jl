using Tela

# Tela.jl stores internally the application settings as a dictionary.
# You can set the settings using the setting" macro. For example:
#
#   julia> setting"width" = 800
#   800
#
# This will set the setting "width" to 800.
# To get the value of a particular setting, use the same macro:
#
#   julia> setting"width"
#   800
#
# To get all the settings, use the @settings macro:
#
#   julia> @settings
#   7-element Tela.Settings
#     :width        │ 800
#     :title        │ "My App"
#     :height       │ 400
#     :vsync        │ 0
#     :framerate    │ Inf
#     :resizable    │ true
#     :antialiasing │ true
#
# One important thing about the settings dictionary is that all keys expect a specific type.
# So, if you try to set a setting with a value that is not convertible to te expected type
# you will get an error:
#
#   julia> setting"width" = "not a number"
#   ERROR: at setting 'width': expected a value convertible to Int64, but a value of type String was used.
#   Stacktrace: ...
#
# Below are the settings you can set for the application and their default values.

# The title of the window (String).
setting"title" = "My App"

# The width of the window (Int).
setting"width" = 400

# The height of the window (Int).
setting"height" = 400

# Whether or not to use vertical synchronization (Int).
# Since in Julia Bool is convertible to Int, you can set this with true/false to enable/disable vsync.
setting"vsync" = false

# The target framerate (Float64).
setting"framerate" = Inf

# Whether or not the window should be resizable by the user (Bool).
setting"resizable" = true

# Whether or not to enable anti-aliasing (Bool).
setting"antialiasing" = true
