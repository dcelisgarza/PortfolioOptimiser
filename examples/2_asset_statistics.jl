#=
# Example 2: Asset statistics
This tutorial follows from [Tutorial 1](https://github.com/dcelisgarza/PortfolioOptimiser.jl/blob/main/examples/0_basic_use.ipynb). If something in the preamble is confusing, it is explained there.

This tutorial focuses on the computation of asset statistics.

## 1. Downloading the data
=#

## using Pkg
## Pkg.add.(["StatsPlots", "GraphRecipes", "MarketData", "Clarabel", "HiGHS", "PrettyTables", "CovarianceEstimation"])
using Clarabel, CovarianceEstimation, DataFrames, Dates, GraphRecipes, HiGHS, MarketData,
      PortfolioOptimiser, PrettyTables, Statistics, StatsBase, StatsPlots, TimeSeries

## These are helper functions for formatting tables.
fmt1 = (v, i, j) -> begin
    if j == 1
        return v
    else
        return isa(v, Number) ? "$(round(v*100, digits=3)) %" : v
    end
end;

assets = Symbol.(["AAL", "AAPL", "AMC", "BB", "BBY", "DELL", "DG", "DRS", "GME", "INTC",
                  "LULU", "MARA", "MCI", "MSFT", "NKLA", "NVAX", "NVDA", "PARA", "PLNT",
                  "SAVE", "SBUX", "SIRI", "STX", "TLRY", "TSLA"])

Date_0 = DateTime(2019, 01, 01)
Date_1 = DateTime(2023, 01, 01)

function get_prices(assets)
    prices = TimeSeries.rename!(yahoo(assets[1],
                                      YahooOpt(; period1 = Date_0, period2 = Date_1))[:AdjClose],
                                assets[1])
    for asset ∈ assets[2:end]
        ## Yahoo doesn't like regular calls to their API.
        sleep(rand() / 10)
        prices = merge(prices,
                       TimeSeries.rename!(yahoo(asset,
                                                YahooOpt(; period1 = Date_0,
                                                         period2 = Date_1))[:AdjClose],
                                          asset), :outer)
    end
    return prices
end

prices = get_prices(assets)

# ## 2. Instantiating an instance of [`Portfolio`](@ref).

portfolio = Portfolio(; prices = prices,
                      ## Continuous optimiser.
                      solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                       :check_sol => (allow_local = true,
                                                                      allow_almost = true),
                                                       :params => Dict("verbose" => false,
                                                                       "max_step_fraction" => 0.7))),
                      ## MIP optimiser for the discrete allocation.
                      alloc_solvers = Dict(:HiGHS => Dict(:solver => HiGHS.Optimizer,
                                                          :check_sol => (allow_local = true,
                                                                         allow_almost = true),
                                                          :params => Dict("log_to_console" => false))));

#=
## 3 Asset statistics
When you first create a [`Portfolio`](@ref) in this way, it does not contain any statistics other than the returns. So we must compute them.

[`PortfolioOptimiser`](https://github.com/dcelisgarza/PortfolioOptimiser.jl) uses the [`StatsAPI.jl`](https://github.com/JuliaStats/StatsAPI.jl) interfaces through [`StatsBase.jl`](https://juliastats.org/StatsBase.jl/stable/). Meaning it is composable with other packages which use the common framework, and it also makes it easy for users to define their custom methods by using Julia's typesystem.

We'll only focus on the expected returns and covariance matrix. The default parameters are the arithmetic mean and sample covariance.
=#

asset_statistics!(portfolio; set_kurt = false, set_skurt = false, set_skew = false,
                  set_sskew = false)

## Save these for later use.
mu1 = copy(portfolio.mu)
cov1 = copy(portfolio.cov)

# We can prove this by computing the arithmetic mean and sample covariance of the returns.
println(isapprox(mu1, vec(mean(portfolio.returns; dims = 1)))) # true
println(isapprox(cov1, cov(portfolio.returns; dims = 1))) # true

#=
These statistics are not very robust, so they're not very reliable. We can make them a bit better by using weights. First we need to explain the estimators. 

### 3.1 Mean estimators

Lets start with the easier one, [`MeanEstimator`](@ref). There are four of these, [`MuSimple`](@ref), [`MuJS`](@ref), [`MuBS`](@ref), [`MuBOP`](@ref). As you can see, they are all subtypes of [`MeanEstimator`](@ref), we will use this later on to define our own method. Lets first focus on the first estimator, which is also the default.

We've already seen its default behaviour, we know from above it's the same as the arithmetic mean. But it can take a vector of [`AbstractWeights`](https://juliastats.org/StatsBase.jl/stable/weights/).

First lets get the number of timestamps `T`, and number of assets `N`. We'll use `T` for defining our weights.
=#

T, N = size(portfolio.returns)

#=
There are a variety of weights, but the only ones that make sense with no prior knowledge are exponential weights. Now lets use this to compute the asset expected returns vector, we do this by passing the argument `mu_type = mu_type_1` to the function, we've also set the `set_cov = false` so it doesn't recompute the covariance.
=#

## Play around with the value of lambda (1/T, in the example) to see the effect it has on the weights and computed expected returns vector.
w = eweights(1:T, 1 / T; scale = true)
mu_type_1 = MuSimple(; w = w)
asset_statistics!(portfolio; mu_type = mu_type_1, set_cov = false, set_kurt = false,
                  set_skurt = false, set_skew = false, set_sskew = false)
mu2 = copy(portfolio.mu)

println(isapprox(mu1, mu2)) # false

#=
The other three estimators included in [`PortfolioOptimiser`](https://github.com/dcelisgarza/PortfolioOptimiser.jl) require a target and a covariance matrix, since they use these to correct the estimate of the arithmetic mean. The available targets are [`GM`](@ref), [`VW`](@ref), [`SE`](@ref), they all default to [`GM`](@ref). They can also take an [`AbstractWeights`](https://juliastats.org/StatsBase.jl/stable/weights/), which they will use to compute the arithmetic mean that is then corrected with the target and covariane matrix. We'll try a few combinations.

The covariance matrix is not needed, if it is empty, it will be computed by [`asset_statistics!`](@ref) from the parameters given to it via `cov_type` even if `set_cov = false`, it just won't replace the old covariance matrix with the one that's been computed for the mean estimator, once the calculation is done, the `sigma` field of the estimator will be set to empty once more. If a covariance matrix is provided, then [`asset_statistics!`](@ref) will use this rather than computing one for it.

Feel free to mix and match, and to play around with various combinations.
=#

mu_type_2 = MuJS(; target = GM())
asset_statistics!(portfolio; mu_type = mu_type_2, set_cov = false, set_kurt = false,
                  set_skurt = false, set_skew = false, set_sskew = false)
mu3 = copy(portfolio.mu)

mu_type_3 = MuBS(; target = VW(), w = w)
asset_statistics!(portfolio; mu_type = mu_type_3, set_cov = false, set_kurt = false,
                  set_skurt = false, set_skew = false, set_sskew = false)
mu4 = copy(portfolio.mu)

## Using a custom covariance with random noise. It's not guaranteed to be positive definite.
noise = randn(N, N) / N^2
noise = noise' * noise
mu_type_4 = MuBOP(; target = SE(), sigma = cov1 + noise)
asset_statistics!(portfolio; mu_type = mu_type_4, set_cov = false, set_kurt = false,
                  set_skurt = false, set_skew = false, set_sskew = false)
mu5 = copy(portfolio.mu)

#=
All targets subtype [`MeanTarget`](@ref). It is possible for users to define a one by creating a concrete subtype of [`MeanTarget`](@ref) and defining a new [`target_mean`](@ref) for the custom target.

```
struct CustomMeanTarget <: MeanTarget
    ...
end
function target_mean(ct::CustomMeanTarget, mu::AbstractVector, sigma::AbstractMatrix, inv_sigma, T::Integer,
                     N::Integer)
    ...                     
end
```

however, this limits the target to using the same data as the current ones. It's easier to define a new concrete subtype of [`MeanEstimator`](@ref). We will do this in the following section.

### 3.2 Defining a custom mean method

In order to define a new method all you need to do is create a new subtype of [`PortfolioOptimiser.MeanEstimator`](@ref) (it's not exported so it must be qualified) and define a new [`StatsBase.mean`](https://juliastats.org/StatsBase.jl/stable/scalarstats/#Weighted-sum-and-mean) function.

This is all we need, we can now define a custom mean that is the same as the [`MuSimple`](@ref), but scales the vector. You can scale the vector uniformly, by providing a scalar, or scale each item individually by providing an `AbstractVector`.
=#

mutable struct MyScaledMean{T1, T2} <: PortfolioOptimiser.MeanEstimator
    scale::T1
    w::T2
end
function MyScaledMean(; scale::Union{<:AbstractVector{<:Real}, Real} = 1, w = nothing)
    return MyScaledMean{typeof(scale), typeof(w)}(scale, w)
end

## We have to turn this into a vec so we can scale by a vector.
function StatsBase.mean(me::MyScaledMean, X::AbstractArray; dims::Int = 1)
    return me.scale .*
           vec((isnothing(me.w) ? mean(X; dims = dims) : mean(X, me.w; dims = dims)))
end

scale = 5
mu_type_5 = MyScaledMean(; scale = scale)
asset_statistics!(portfolio; mu_type = mu_type_5, set_cov = false, set_kurt = false,
                  set_skurt = false, set_skew = false, set_sskew = false)
mu6 = copy(portfolio.mu)
## Should be a vector of 5's.
println(mu6 ./ mu1)

scale = 1:N
mu_type_6 = MyScaledMean(; scale = scale)
asset_statistics!(portfolio; mu_type = mu_type_6, set_cov = false, set_kurt = false,
                  set_skurt = false, set_skew = false, set_sskew = false)
mu7 = copy(portfolio.mu)
## Should be a vector going from 1 to N.
println(mu7 ./ mu1)

#=
### 3.3 Covariance estimators

[`PortfolioOptimiser`](https://github.com/dcelisgarza/PortfolioOptimiser.jl) comes with quite a few covariance estimators. However, it is best to wrap them all with [`PortCovCor`](@ref). This is because it contains methods for denoising, fixing non-positive definite matrices, and using a graph-based algorithm for computing the covariance based on its relational structure.

[Portfoliooptimiser](https://github.com/dcelisgarza/PortfolioOptimiser.jl)'s mean and covariance estimators are based on the idea of subtyping [`StatsBase.CovarianceEstimator`](https://juliastats.org/StatsBase.jl/stable/cov/#StatsBase.CovarianceEstimator) to specialise the `cov` function. The same idea is used in 
=#

## 
ce0 = SimpleCovariance(; corrected = true)
ce1 = CovFull()
ce2 = CovSemi()
ce3 = CorMutualInfo()
ce4 = CorDistance()
ce5 = CorLTD()
ce6 = CorGerber0()
ce7 = CorGerber1()
ce8 = CorGerber2()
ce9 = CorSB0()
ce10 = CorSB1()
ce11 = CorGerberSB0()
ce12 = CorGerberSB1()

ce = PortCovCor(; ce = ce1)
