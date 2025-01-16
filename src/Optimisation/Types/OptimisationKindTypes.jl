"""
    abstract type AbstractOptimType end

Abstract type for the different types of optimisations.
"""
abstract type AbstractOptimType end

"""
    abstract type OptimType <: AbstractOptimType end

Abstract type for optimisations that are not hierarchical.
"""
abstract type OptimType <: AbstractOptimType end

"""
    abstract type HCOptimType <: AbstractOptimType end

Abstract type for hierarchical optimisations.
"""
abstract type HCOptimType <: AbstractOptimType end

"""
    abstract type AbstractScalarisation end

Abstract type for scalarisation functions used when simultaneously optimising for multiple risk measures.
"""
abstract type AbstractScalarisation end

"""
    struct ScalarSum <: AbstractScalarisation end

Scalarises the risk measures as a weighted sum.

```math
\\begin{align}
    r &= \\bm{r} \\cdot \\bm{w}
\\end{align}
```

Where:

  - ``r`` is the scalarised risk.
  - ``\\bm{r}`` is the vector of risk measures.
  - ``\\bm{w}`` is the corresponding vector of risk measure weights
  - ``\\cdot`` is the dot product.
"""
struct ScalarSum <: AbstractScalarisation end

"""
    struct ScalarMax <: AbstractScalarisation end

Scalarises the risk measures by taking the maximum of them.

```math
\\begin{align}
    r &= \\max \\left( \\bm{r} \\odot \\bm{w} \\right)
\\end{align}
```

Where:

  - ``r`` is the scalarised risk.
  - ``\\bm{r}`` is the vector of risk measures.
  - ``\\bm{w}`` is the corresponding vector of risk measure weights.
  - ``\\odot`` is the Hadamard (element-wise) multiplication.
"""
struct ScalarMax <: AbstractScalarisation end

"""
    mutable struct ScalarLogSumExp{T1 <: Real} <: AbstractScalarisation end

Scalarises the risk measures as the log_sum_exp of the weighted risk measures.

```math
\\begin{align}
    r &= \\frac{1}{\\gamma} \\log \\left( \\sum_{i = 1}^{N} \\exp(\\gamma r_i w_i) \\right)
\\end{align}
```

Where:

  - ``r`` is the scalarised risk.
  - ``r_i`` is the ``i``-th risk measure.
  - ``w_i`` is the weight of the ``i``-th risk measure.
  - ``\\gamma`` is a parameter that controls the shape of the scalarisation.

# Parameters

  - `gamma::Real = 1.0`: `gamma > 0`. As `gamma` approches 0, the scalarisation approaches [`ScalarSum`](@ref). As `gamma` approaches infinity, the scalarisation approaches [`ScalarMax`](@ref).
"""
mutable struct ScalarLogSumExp{T1 <: Real} <: AbstractScalarisation
    gamma::T1
end
function ScalarLogSumExp(; gamma::Real = 1.0)
    @smart_assert(zero(gamma) <= gamma)
    return ScalarLogSumExp{typeof(gamma)}(gamma)
end
function Base.setproperty!(obj::ScalarLogSumExp, sym::Symbol, val)
    if sym == :gamma
        @smart_assert(zero(val) <= val)
    end
    return setfield!(obj, sym, val)
end

"""
```
struct Trad <: OptimType end
```
"""
mutable struct Trad{T1, T2} <: OptimType
    rm::Union{AbstractVector, <:RiskMeasure}
    obj::ObjectiveFunction
    kelly::RetType
    class::PortClass
    w_ini::T1
    custom_constr::CustomConstraint
    custom_obj::CustomObjective
    ohf::T2
    scalarisation::AbstractScalarisation
    str_names::Bool
end
function Trad(; rm::Union{AbstractVector, <:RiskMeasure} = Variance(),
              obj::ObjectiveFunction = MinRisk(), kelly::RetType = NoKelly(),
              class::PortClass = Classic(),
              w_ini::AbstractVector = Vector{Float64}(undef, 0),
              custom_constr::CustomConstraint = NoCustomConstraint(),
              custom_obj::CustomObjective = NoCustomObjective(), ohf::Real = 1.0,
              scalarisation::AbstractScalarisation = ScalarSum(), str_names::Bool = false)
    return Trad{typeof(w_ini), typeof(ohf)}(rm, obj, kelly, class, w_ini, custom_constr,
                                            custom_obj, ohf, scalarisation, str_names)
end

"""
```
struct RP <: OptimType end
```
"""
mutable struct RP{T1} <: OptimType
    rm::Union{AbstractVector, <:RiskMeasure}
    kelly::RetType
    class::PortClass
    w_ini::T1
    custom_constr::CustomConstraint
    custom_obj::CustomObjective
    scalarisation::AbstractScalarisation
    str_names::Bool
end
function RP(; rm::Union{AbstractVector, <:RiskMeasure} = Variance(),
            kelly::RetType = NoKelly(), class::PortClass = Classic(),
            w_ini::AbstractVector = Vector{Float64}(undef, 0),
            custom_constr::CustomConstraint = NoCustomConstraint(),
            custom_obj::CustomObjective = NoCustomObjective(),
            scalarisation::AbstractScalarisation = ScalarSum(), str_names::Bool = false)
    return RP{typeof(w_ini)}(rm, kelly, class, w_ini, custom_constr, custom_obj,
                             scalarisation, str_names)
end

"""
```
abstract type RRPVersion end
```
"""
abstract type RRPVersion end

"""
```
struct BasicRRP <: RRPVersion end
```
"""
struct BasicRRP <: RRPVersion end

"""
```
struct RegRRP <: RRPVersion end
```
"""
struct RegRRP <: RRPVersion end

"""
```
@kwdef mutable struct RegPenRRP{T1 <: Real} <: RRPVersion
    penalty::T1 = 1.0
end
```
"""
mutable struct RegPenRRP{T1} <: RRPVersion
    penalty::T1
end
function RegPenRRP(; penalty::Real = 1.0)
    return RegPenRRP(penalty)
end

"""
```
@kwdef mutable struct RRP <: OptimType
    version::RRPVersion = BasicRRP()
end
```
"""
mutable struct RRP{T1} <: OptimType
    version::RRPVersion
    kelly::RetType
    class::PortClass
    w_ini::T1
    custom_constr::CustomConstraint
    custom_obj::CustomObjective
    str_names::Bool
end
function RRP(; version::RRPVersion = BasicRRP(), kelly::RetType = NoKelly(),
             class::PortClass = Classic(),
             w_ini::AbstractVector = Vector{Float64}(undef, 0),
             custom_constr::CustomConstraint = NoCustomConstraint(),
             custom_obj::CustomObjective = NoCustomObjective(), str_names::Bool = false,)
    return RRP{typeof(w_ini)}(version, kelly, class, w_ini, custom_constr, custom_obj,
                              str_names)
end
function Base.getproperty(obj::RRP, sym::Symbol)
    return if sym == :rm
        nothing
    else
        getfield(obj, sym)
    end
end

"""
```
@kwdef mutable struct NOC{T1 <: Real, T2 <: AbstractVector{<:Real},
                          T3 <: AbstractVector{<:Real}, T4 <: AbstractVector{<:Real},
                          T5 <: AbstractVector{<:Real}, T6 <: AbstractVector{<:Real}} <:
                      OptimType
    type::Trad = Trad()
    bins::T1 = 20.0
    w_opt::T2 = Vector{Float64}(undef, 0)
    w_min::T3 = Vector{Float64}(undef, 0)
    w_max::T4 = Vector{Float64}(undef, 0)
    w_min_ini::T5 = Vector{Float64}(undef, 0)
    w_max_ini::T6 = Vector{Float64}(undef, 0)
end
```
"""
mutable struct NOC{T1, T2, T3, T4, T5, T6, T7, T8} <: OptimType
    flag::Bool
    bins::T1
    w_opt::T2
    w_min::T3
    w_max::T4
    w_min_ini::T5
    w_max_ini::T6
    rm::Union{AbstractVector, <:RiskMeasure}
    obj::ObjectiveFunction
    kelly::RetType
    class::PortClass
    w_ini::T7
    custom_constr::CustomConstraint
    custom_obj::CustomObjective
    ohf::T8
    scalarisation::AbstractScalarisation
    str_names::Bool
end
function NOC(; flag::Bool = true, bins::Real = 20.0,
             w_opt::AbstractVector{<:Real} = Vector{Float64}(undef, 0),
             w_min::AbstractVector{<:Real} = Vector{Float64}(undef, 0),
             w_max::AbstractVector{<:Real} = Vector{Float64}(undef, 0),
             w_min_ini::AbstractVector{<:Real} = Vector{Float64}(undef, 0),
             w_max_ini::AbstractVector{<:Real} = Vector{Float64}(undef, 0),
             rm::Union{AbstractVector, <:RiskMeasure} = Variance(),
             obj::ObjectiveFunction = MinRisk(), kelly::RetType = NoKelly(),
             class::PortClass = Classic(),
             w_ini::AbstractVector{<:Real} = Vector{Float64}(undef, 0),
             custom_constr::CustomConstraint = NoCustomConstraint(),
             custom_obj::CustomObjective = NoCustomObjective(), ohf::Real = 1.0,
             scalarisation::AbstractScalarisation = ScalarSum(), str_names::Bool = false)
    return NOC{typeof(bins), typeof(w_opt), typeof(w_min), typeof(w_max), typeof(w_min_ini),
               typeof(w_max_ini), typeof(w_ini), typeof(ohf)}(flag, bins, w_opt, w_min,
                                                              w_max, w_min_ini, w_max_ini,
                                                              rm, obj, kelly, class, w_ini,
                                                              custom_constr, custom_obj,
                                                              ohf, scalarisation, str_names)
end

abstract type HCOptWeightFinaliser end
mutable struct HWF{T1} <: HCOptWeightFinaliser
    max_iter::T1
end
function HWF(; max_iter::Integer = 100)
    return HWF{typeof(max_iter)}(max_iter)
end
mutable struct JWF{T1 <: Integer} <: HCOptWeightFinaliser
    type::T1
end
function JWF(; type::Integer = 1)
    @smart_assert(type ∈ (1, 2, 3, 4))
    return JWF{typeof(type)}(type)
end
function Base.setproperty!(obj::JWF, sym::Symbol, val)
    if sym == :type
        @smart_assert(val ∈ (1, 2, 3, 4))
    end
    return setfield!(obj, sym, val)
end

"""
```
struct HRP <: HCOptimType end
```
"""
mutable struct HRP <: HCOptimType
    rm::Union{AbstractVector, <:AbstractRiskMeasure}
    class::PortClass
    scalarisation::AbstractScalarisation
    finaliser::HCOptWeightFinaliser
end
function HRP(; rm::Union{AbstractVector, <:AbstractRiskMeasure} = Variance(),
             class::PortClass = Classic(),
             scalarisation::AbstractScalarisation = ScalarSum(),
             finaliser::HCOptWeightFinaliser = HWF())
    return HRP(rm, class, scalarisation, finaliser)
end

mutable struct SchurParams{T1, T2, T3, T4}
    rm::RMSigma
    gamma::T1
    prop_coef::T2
    tol::T3
    max_iter::T4
end
function SchurParams(; rm::RMSigma = Variance(;), gamma::Real = 0.5, prop_coef::Real = 0.5,
                     tol::Real = 1e-2, max_iter::Integer = 10)
    @smart_assert(zero(gamma) <= gamma <= one(gamma))
    @smart_assert(zero(prop_coef) <= prop_coef <= one(prop_coef))
    @smart_assert(zero(tol) < tol)
    @smart_assert(zero(max_iter) < max_iter)
    return SchurParams{typeof(gamma), typeof(prop_coef), typeof(tol), typeof(max_iter)}(rm,
                                                                                        gamma,
                                                                                        prop_coef,
                                                                                        tol,
                                                                                        max_iter)
end
function Base.setproperty!(obj::SchurParams, sym::Symbol, val)
    if sym ∈ (:gamma, :prop_coef)
        @smart_assert(zero(val) <= val <= one(val))
    elseif sym ∈ (:tol, :max_iter)
        @smart_assert(zero(val) < val)
    end
    return setfield!(obj, sym, val)
end
mutable struct SchurHRP <: HCOptimType
    params::Union{AbstractVector, <:SchurParams}
    class::PortClass
    finaliser::HCOptWeightFinaliser
end
function SchurHRP(; params::Union{AbstractVector, <:SchurParams} = SchurParams(),
                  class::PortClass = Classic(), finaliser::HCOptWeightFinaliser = HWF())
    return SchurHRP(params, class, finaliser)
end

"""
```
struct HERC <: HCOptimType end
```
"""
mutable struct HERC <: HCOptimType
    rm::Union{AbstractVector, <:AbstractRiskMeasure}
    rm_o::Union{AbstractVector, <:AbstractRiskMeasure}
    class::PortClass
    class_o::PortClass
    scalarisation::AbstractScalarisation
    scalarisation_o::AbstractScalarisation
    finaliser::HCOptWeightFinaliser
end
function HERC(; rm::Union{AbstractVector, <:AbstractRiskMeasure} = Variance(),
              rm_o::Union{AbstractVector, <:AbstractRiskMeasure} = rm,
              class::PortClass = Classic(), class_o::PortClass = class,
              scalarisation::AbstractScalarisation = ScalarSum(),
              scalarisation_o::AbstractScalarisation = scalarisation,
              finaliser::HCOptWeightFinaliser = HWF())
    return HERC(rm, rm_o, class, class_o, scalarisation, scalarisation_o, finaliser)
end

abstract type AbstractNCOModify end
struct NoNCOModify <: AbstractNCOModify end

mutable struct NCOArgs
    type::AbstractOptimType
    pre_modify::AbstractNCOModify
    post_modify::AbstractNCOModify
    port_kwargs::NamedTuple
    stats_kwargs::NamedTuple
    wc_kwargs::NamedTuple
    factor_kwargs::NamedTuple
    cluster_kwargs::NamedTuple
end
function NCOArgs(; type::AbstractOptimType = Trad(),
                 pre_modify::AbstractNCOModify = NoNCOModify(),
                 post_modify::AbstractNCOModify = NoNCOModify(),
                 port_kwargs::NamedTuple = (;), stats_kwargs::NamedTuple = (;),
                 wc_kwargs::NamedTuple = (;), factor_kwargs::NamedTuple = (;),
                 cluster_kwargs::NamedTuple = (;))
    return NCOArgs(type, pre_modify, post_modify, port_kwargs, stats_kwargs, wc_kwargs,
                   factor_kwargs, cluster_kwargs)
end
"""
```
mutable struct NCO <: HCOptimType
    internal::NCOArgs
    external::NCOArgs
    finaliser::HCOptWeightFinaliser
end
```
"""
mutable struct NCO <: HCOptimType
    internal::NCOArgs
    external::NCOArgs
    finaliser::HCOptWeightFinaliser
end
function NCO(; internal::NCOArgs = NCOArgs(;), external::NCOArgs = internal,
             finaliser::HCOptWeightFinaliser = HWF())
    return NCO(internal, external, finaliser)
end
function Base.getproperty(nco::NCO, sym::Symbol)
    if sym ∈
       (:rm, :obj, :kelly, :class, :scalarisation, :w_ini, :custom_constr, :custom_obj,
        :str_names)
        type = nco.internal.type
        isa(type, NCO) ? getproperty(type, sym) : getfield(type, sym)
    elseif sym ∈
           (:rm_o, :obj_o, :kelly_o, :class_o, :scalarisation_o, :w_ini_o, :custom_constr_o,
            :custom_obj_o, :str_names_o)
        type = nco.external.type
        if isa(type, NCO)
            getproperty(type, sym)
        else
            str_sym = string(sym)
            sym = contains(str_sym, "_o") ? Symbol(str_sym[1:(end - 2)]) : sym
            getfield(type, sym)
        end
    else
        getfield(nco, sym)
    end
end

for (op, name) ∈ zip((Trad, RP, RRP, NOC, HRP, HERC, NCO, SchurHRP),
                     ("Trad", "RP", "RRP", "NOC", "HRP", "HERC", "NCO", "SchurHRP"))
    eval(quote
             function Base.String(::$op)
                 return $name
             end
             function Base.Symbol(s::$op)
                 return Symbol($name)
             end
         end)
end

export Trad, RP, BasicRRP, RegRRP, RegPenRRP, RRP, NOC, HRP, HERC, NCO, NCOArgs, SchurHRP,
       SchurParams, HWF, JWF, ScalarSum, ScalarMax, ScalarLogSumExp
