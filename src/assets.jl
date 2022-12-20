const Assets = Dict{String, Vector{String}}()

struct AssetNotFound <: Exception
    key::String
    path::String
end

function Base.showerror(io::IO, err::AssetNotFound)
    key = repr(err.key)
    path = repr(err.path)

    if isempty(err.key)
        print(io, "could not find asset $path.")
    else
        print(io, "could not find asset $path with asset key $key.")
    end
end

"""
    asset(path; error=true) -> String
    asset(key, path; error=true) -> String

Searches for a `path` asset from a specific asset `key`,
or if no key is provided, search every asset path.

If `error` is set to `true`, throws [`AssetNotFound`](@ref) error if
the `path` could not be found, otherwise, returns an empty string.

See also [`@assets`](@ref), [`@assets_str`](@ref) and [`@asset_str`](@ref).
"""
function asset(key::AbstractString, file::AbstractString; error::Bool = true)
    for path in get(Assets, key, String[])
        found = joinpath(path, file)
        if ispath(found)
            return found
        end
    end

    if error
        throw(AssetNotFound(key, file))
    else
        return ""
    end
end

function asset(file::AbstractString; error::Bool = true)
    for key in keys(Assets)
        found = asset(key, file, error=false)
        isempty(found) || return found
    end

    if error
        throw(AssetNotFound("", file))
    else
        return ""
    end
end

"""
    @assets() -> Dict{String, Vector{String}}
    @assets(key) -> Vector{String}

Returns the application `assets`.

`assets` is a global dictionary that associates `String` keys with lists of paths.

By default, `assets` is empty, but you can add new entries using the helper macros:

```julia
julia> @assets["files"] = ["src", "examples", "test"];

julia> assets"fonts" = ["assets/fonts/Roboto", "assets/fonts/NotoEmoji"];

julia> @assets
Dict{String, Vector{String}} with 2 entries:
  "fonts" => ["assets/fonts/Roboto", "assets/fonts/NotoEmoji"]
  "files" => ["src", "examples", "test"]
```

You can also use the `getindex` syntax to retrieve the list for a specific `key`:

```julia
julia> @assets["fonts"]
2-element Vector{String}:
 "assets/fonts/Roboto"
 "assets/fonts/NotoEmoji"

julia> @assets["files"]
3-element Vector{String}:
 "src"
 "examples"
 "test"
```

See also [`@assets_str`](@ref) and [`@asset_str`](@ref).
"""
macro assets() :(Assets) end
macro assets(i) getter(:(Assets), i, :ref) end

"""
    @assets_str(key) -> Vector{String}

Gets/Sets the list of asset paths associated with `key`.

**Examples:**

```julia
julia> assets"files" = ["some/path", "foo/bar"]
2-element Vector{String}:
 "some/path"
 "foo/bar"

julia> assets"fonts" = ["fonts/Roboto", "fonts/NotoEmoji"]
2-element Vector{String}:
 "fonts/Roboto"
 "fonts/NotoEmoji"

julia> assets"files"
2-element Vector{String}:
 "some/path"
 "foo/bar"

julia> assets"fonts"
2-element Vector{String}:
 "fonts/Roboto"
 "fonts/NotoEmoji"
```

See also [`@assets`](@ref) and [`@asset_str`](@ref).
"""
macro assets_str(s) :(@assets[$s]) end

"""
    asset"path" -> String
    asset"key:path" -> String

Searches for a `path` asset from a specific asset `key`,
or if no key is provided, search every asset path.

Throws an [`AssetNotFound`](@ref) error if `path` is not found.

**Examples:**

```julia
shell> tree .
.
├── assets
│   ├── fonts
│   │   ├── NotoEmoji.ttf
│   │   └── Roboto.ttf
│   └── images
│       ├── image1.png
│       └── image2.png
└── src
    ├── bar.jl
    └── foo.jl

4 directories, 6 files

julia> assets"src" = ["src"];

julia> assets"assets" = ["assets", "assets/images", "assets/fonts"];

julia> assets"images" = ["assets/images"];

julia> assets"fonts" = ["assets/fonts"];

julia> @assets
Dict{String, Vector{String}} with 4 entries:
  "images" => ["assets/images"]
  "fonts"  => ["assets/fonts"]
  "src"    => ["src"]
  "assets" => ["assets", "assets/images", "assets/fonts"]

julia> asset"Roboto.ttf"
"assets/fonts/Roboto.ttf"

julia> asset"images:image1.png"
"assets/images/image1.png"

julia> asset"src:foo.jl"
"src/foo.jl"

julia> asset"non-existent:foo/bar.jl"
ERROR: could not find asset "foo/bar.jl" with asset key "non-existent".
Stacktrace: ...

julia> asset"nont-existent-file"
ERROR: could not find asset "nont-existent-file".
Stacktrace: ...
```
"""
macro asset_str(str)
    if ':' in str
        # asset"key:path"
        args = (map(strip, split(str, ":"))...,)
    else
        # asset"path"
        args = (strip(str),)
    end

    return Expr(:call, :asset, args...)
end

const TELA_ASSETS = joinpath(dirname(@__DIR__), "assets")

const TELA_FONTS = (;
    Roboto = (;
        Regular     = joinpath(TELA_ASSETS, "fonts", "Roboto", "Roboto-Regular.ttf"),
        Bold        = joinpath(TELA_ASSETS, "fonts", "Roboto", "Roboto-Bold.ttf"),
        Italic      = joinpath(TELA_ASSETS, "fonts", "Roboto", "Roboto-Italic.ttf"),
        BoldItalic  = joinpath(TELA_ASSETS, "fonts", "Roboto", "Roboto-BoldItalic.ttf"),
    ),
    NotoEmoji = (;
        Regular = joinpath(TELA_ASSETS, "fonts", "NotoEmoji", "NotoEmoji-Regular.ttf"),
        Bold    = joinpath(TELA_ASSETS, "fonts", "NotoEmoji", "NotoEmoji-Bold.ttf"),
    )
)

function loadfonts()
    sans = (;
        regular     = loadfont("sans", TELA_FONTS.Roboto.Regular),
        bold        = loadfont("sans-bold", TELA_FONTS.Roboto.Bold),
        italic      = loadfont("sans-italic", TELA_FONTS.Roboto.Italic),
        bold_italic = loadfont("sans-bold-italic", TELA_FONTS.Roboto.BoldItalic)
    )

    emoji = (;
        regular = loadfont("emoji", TELA_FONTS.NotoEmoji.Regular),
        bold    = loadfont("emoji", TELA_FONTS.NotoEmoji.Bold),
    )

    fallbackfont(sans.regular, emoji.regular)
    fallbackfont(sans.italic, emoji.regular)
    fallbackfont(sans.bold, emoji.bold)
    fallbackfont(sans.bold_italic, emoji.bold)
end
