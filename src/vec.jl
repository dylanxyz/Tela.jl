struct Vec{N, T <: Real} <: AbstractVector{T}
    data::NTuple{N, T}
end

Vec(coords::Real...) = Vec(promote(coords...))
Vec{N, T}(coords::Vararg{<:Real, N}) where {T <: Real, N} = Vec{N, T}(promote(coords...))

Base.firstindex(::Vec) = 1
Base.lastindex(::Vec{N}) where {N} = N
Base.eltype(::Vec{N, T}) where {N, T} = T
Base.size(::Vec{N}, dim=1) where {N} = (N,)
Base.strides(::Vec) = (1,)

Base.getindex(p::Vec) = getfield(p, 1)

function Base.getindex(p::Vec, i)
    checkbounds(p, i)
    return getfield(p, 1)[i]
end

Base.propertynames(::Vec{1}) = (:x,)
Base.propertynames(::Vec{2}) = (:x, :y)
Base.propertynames(::Vec{3}) = (:x, :y, :z)
Base.propertynames(::Vec{4}) = (:x, :y, :z, :w)

function Base.getproperty(p::Vec{N}, s::Symbol) where {N}
    s == :x && N >= 1 && return @inbounds p[1]
    s == :y && N >= 2 && return @inbounds p[2]
    s == :z && N >= 3 && return @inbounds p[3]
    s == :w && N >= 4 && return @inbounds p[4]
    error("Type $(typeof(p)) has no field $s")
end

Base.iterate(p::Vec, i=1) = iterate(getfield(p, 1), i)

const Vec2{T} = Vec{2, T}
const Vec3{T} = Vec{3, T}
const Vec4{T} = Vec{4, T}

const Vec2i = Vec2{Int}
const Vec3i = Vec3{Int}
const Vec4i = Vec4{Int}

const Vec2f = Vec2{Float64}
const Vec3f = Vec3{Float64}
const Vec4f = Vec4{Float64}

const Vec2f0 = Vec2{Float32}
const Vec3f0 = Vec3{Float32}
const Vec4f0 = Vec4{Float32}

Vec{N, T}(v::AbstractVector{<:Real}) where {N, T <: Real} = Vec{N, T}(v...)
Vec(v::AbstractVector{T}) where {T} = Vec{length(v), T}(v)

Base.convert(::Type{Vec{N, T}}, v::AbstractVector{<:Real}) where {N, T <: Real} = Vec{N, T}(v)
Base.promote_rule(::Type{Vec{N, T}}, ::Type{<:AbstractVector{S}}) where {N, T, S} = Vec{N, promote_type(T, S)}

-(p::Vec{N, T}) where {N, T} = Vec{N, T}(-1 .* p[])

+(a::Vec{N}, b::Vec{N}) where {N} = Vec(a[] .+ b[])
-(a::Vec{N}, b::Vec{N}) where {N} = Vec(a[] .- b[])

+(a::Vec, b::Vector{<:Real}) = Vec(a[] .+ b)
+(a::Vector{<:Real}, b::Vec) = Vec(a .+ b[])

-(a::Vec, b::Vector{<:Real}) = Vec(a[] .- b)
-(a::Vector{<:Real}, b::Vec) = Vec(a .- b[])

*(k::Real, p::Vec) = Vec(k .* p[])
*(p::Vec, k::Real) = Vec(k .* p[])

/(k::Real, p::Vec) = Vec(p[] ./ k)
/(p::Vec, k::Real) = Vec(p[] ./ k)

Base.abs2(p::Vec{N}) where {N} = sum(@inbounds(p[i]^2) for i in 1:N)
Base.abs(p::Vec) = sqrt(abs2(p))

"""
    limit(p::Point, limit) -> Point

Limits the magnitude of `p` by `limit` if ``abs2(p) > limit^2``.

This function is equivalent to:

    abs2(p) > limit^2 ? limit * (p / abs(p)) : p
"""
limit(p::Vec, limit::Real) = abs2(p) > limit^2 ? limit * (p / abs(p)) : p

"""
    mag(m, p::Point) -> Point

Returns a point with the same direction as `p` but with magnitude `m`.

This function is equivalent to:

    m * (p / abs(p))
"""
mag(m::Real, p::Vec) = m * (p / abs(p))
