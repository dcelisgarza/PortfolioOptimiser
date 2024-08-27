module PortfolioOptimiserMakieExt
using PortfolioOptimiser, Makie, SmartAsserts, Statistics, MultivariateStats, Distributions,
      Clustering, Graphs, SimpleWeightedGraphs, LinearAlgebra

import PortfolioOptimiser: AbstractPortfolio, RiskMeasure, RetType

"""
```
plot_returns(timestamps, assets, returns, weights; per_asset = false, kwargs...)
```
"""
function PortfolioOptimiser.plot_returns(timestamps, assets, returns, weights;
                                         per_asset = false)
    f = Figure()
    if per_asset
        ax = Axis(f[1, 1]; xlabel = "Date", ylabel = "Asset Cummulative Returns")
        ret = returns .* transpose(weights)
        ret = vcat(zeros(1, length(weights)), ret)
        ret .+= 1
        ret = cumprod(ret; dims = 1)
        ret = ret[2:end, :]
        for (i, asset) ∈ enumerate(assets)
            lines!(ax, timestamps, view(ret, :, i); label = asset)
        end
    else
        ax = Axis(f[1, 1]; xlabel = "Date", ylabel = "Portfolio Cummulative Returns")
        ret = returns * weights
        pushfirst!(ret, 0)
        ret .+= 1
        ret = cumprod(ret)
        popfirst!(ret)
        lines!(ax, timestamps, ret; label = "Portfolio")
    end
    axislegend(; position = :lt, merge = true)
    return f
end
function PortfolioOptimiser.plot_returns(port::AbstractPortfolio,
                                         type = isa(port, HCPortfolio) ? :HRP : :Trad;
                                         per_asset = false)
    return PortfolioOptimiser.plot_returns(port.timestamps, port.assets, port.returns,
                                           port.optimal[type].weights;
                                           per_asset = per_asset)
end

function PortfolioOptimiser.plot_bar(assets, weights)
    f = Figure()
    ax = Axis(f[1, 1]; xticks = (1:length(assets), assets),
              ylabel = "Portfolio Composition, %", xticklabelrotation = pi / 2)
    barplot!(ax, weights * 100)
    return f
end
function PortfolioOptimiser.plot_bar(port::AbstractPortfolio,
                                     type = isa(port, HCPortfolio) ? :HRP : :Trad;
                                     kwargs...)
    return PortfolioOptimiser.plot_bar(port.assets, port.optimal[type].weights, kwargs...)
end

function PortfolioOptimiser.plot_risk_contribution(assets::AbstractVector,
                                                   w::AbstractVector, X::AbstractMatrix;
                                                   rm::RiskMeasure = SD(),
                                                   V::AbstractMatrix = Matrix{Float64}(undef,
                                                                                       0,
                                                                                       0),
                                                   SV::AbstractMatrix = Matrix{Float64}(undef,
                                                                                        0,
                                                                                        0),
                                                   percentage::Bool = false,
                                                   erc_line::Bool = true, t_factor = 252,
                                                   delta::Real = 1e-6,
                                                   marginal::Bool = false, kwargs...)
    rc = risk_contribution(rm, w; X = X, V = V, SV = SV, delta = delta, marginal = marginal,
                           kwargs...)

    DDs = (DaR, MDD, ADD, CDaR, EDaR, RDaR, UCI, DaR_r, MDD_r, ADD_r, CDaR_r, EDaR_r,
           RDaR_r, UCI_r)

    if !any(typeof(rm) .<: DDs)
        rc *= sqrt(t_factor)
    end
    ylabel = "Risk Contribution"
    if percentage
        rc .= 100 * rc / sum(rc)
        ylabel *= ", %"
    end

    rmstr = string(rm)
    rmstr = rmstr[1:(findfirst('{', rmstr) - 1)]
    title = "Risk Contribution - $rmstr"
    if any(typeof(rm) .<:
           (CVaR, TG, EVaR, RVaR, RCVaR, RTG, CDaR, EDaR, RDaR, CDaR_r, EDaR_r, RDaR_r))
        title *= " α = $(round(rm.alpha*100, digits=2))%"
    end
    if any(typeof(rm) .<: (RCVaR, RTG))
        title *= ", β = $(round(rm.beta*100, digits=2))%"
    end
    if any(typeof(rm) .<: (RVaR, RDaR, RDaR_r))
        title *= ", κ = $(round(rm.kappa, digits=2))"
    end

    f = Figure()
    ax = Axis(f[1, 1]; xticks = (1:length(assets), assets), title = title, ylabel = ylabel,
              xticklabelrotation = pi / 2)
    barplot!(ax, rc)

    if erc_line
        if percentage
            erc = 100 / length(rc)
        else
            erc = calc_risk(rm, w; X = X, V = V, SV = SV)

            erc /= length(rc)

            if !any(typeof(rm) .<: DDs)
                erc *= sqrt(t_factor)
            end
        end

        hlines!(ax, erc)
    end

    return f
end
function PortfolioOptimiser.plot_risk_contribution(port::AbstractPortfolio,
                                                   type = if isa(port, HCPortfolio)
                                                       :HRP
                                                   else
                                                       :Trad
                                                   end; X = port.returns,
                                                   rm::RiskMeasure = SD(),
                                                   percentage::Bool = false,
                                                   erc_line::Bool = true, t_factor = 252,
                                                   delta::Real = 1e-6,
                                                   marginal::Bool = false, kwargs...)
    solver_flag, sigma_flag = set_rm_properties(rm, port.solvers, port.cov)
    fig = PortfolioOptimiser.plot_risk_contribution(port.assets, port.optimal[type].weights,
                                                    X; rm = rm, V = port.V, SV = port.SV,
                                                    percentage = percentage,
                                                    erc_line = erc_line,
                                                    t_factor = t_factor, delta = delta,
                                                    marginal = marginal, kwargs...)
    unset_set_rm_properties(rm, solver_flag, sigma_flag)

    return fig
end

function PortfolioOptimiser.plot_frontier(frontier;
                                          X::AbstractMatrix = Matrix{Float64}(undef, 0, 0),
                                          mu::AbstractVector = Vector{Float64}(undef, 0),
                                          rf::Real = 0.0, rm::RiskMeasure = SD(),
                                          kelly::RetType = NoKelly(), t_factor = 252,
                                          palette = :Spectral)
    risks = copy(frontier[:risk])
    weights = Matrix(frontier[:weights][!, 2:end])

    if isa(kelly, NoKelly)
        ylabel = "Expected Arithmetic Return"
        rets = transpose(weights) * mu
    else
        ylabel = "Expected Kelly Return"
        rets = 1 / size(X, 1) * vec(sum(log.(1 .+ X * weights); dims = 1))
    end

    rets .*= t_factor

    if !any(typeof(rm) .<: (MDD, ADD, CDaR, EDaR, RDaR, UCI))
        risks .*= sqrt(t_factor)
    end

    ratios = (rets .- rf) ./ risks
    N = length(ratios)

    title = "$(get_rm_string(rm))"
    if any(typeof(rm) .<: (CVaR, TG, EVaR, RVaR, RCVaR, RTG, CDaR, EDaR, RDaR))
        title *= " α = $(round(rm.alpha*100, digits=2))%"
    end
    if any(typeof(rm) .<: (RCVaR, RTG))
        title *= ", β = $(round(rm.beta*100, digits=2))%"
    end
    if any(typeof(rm) .<: (RVaR, RDaR))
        title *= ", κ = $(round(rm.kappa, digits=2))"
    end

    f = Figure()
    ax = Axis(f[1, 1]; title = title, ylabel = ylabel, xlabel = "Expected Risk")
    Colorbar(f[1, 2]; label = "Risk Adjusted Return Ratio", limits = extrema(ratios),
             colormap = palette)

    if frontier[:sharpe]
        scatter!(ax, risks[1:(end - 1)], rets[1:(end - 1)]; color = ratios[1:(N - 1)],
                 colormap = palette, marker = :circle, markersize = 15)
        scatter!(ax, risks[end], rets[end]; color = cgrad(palette)[ratios[N]],
                 marker = :star5, markersize = 15, label = "Max Risk Adjusted Return Ratio")
    else
        scatter(ax, risks[1:end], rets[1:end]; color = ratios, colormap = palette)
    end
    axislegend(ax; position = :rb)

    return f
end
function PortfolioOptimiser.plot_frontier(port::AbstractPortfolio, key = nothing;
                                          X::AbstractMatrix = port.returns,
                                          mu::AbstractVector = port.mu,
                                          rm::RiskMeasure = SD(), rf::Real = 0.0,
                                          kelly::RetType = NoKelly(), t_factor = 252,
                                          palette = :Spectral)
    if isnothing(key)
        key = get_rm_string(rm)
    end
    return PortfolioOptimiser.plot_frontier(port.frontier[key]; X = X, mu = mu, rf = rf,
                                            rm = rm, kelly = kelly, t_factor = t_factor,
                                            palette = palette)
end

function PortfolioOptimiser.plot_frontier_area(frontier; rm::RiskMeasure = SD(),
                                               t_factor = 252, palette = :Spectral)
    risks = copy(frontier[:risk])
    assets = reshape(frontier[:weights][!, "tickers"], 1, :)
    weights = Matrix(frontier[:weights][!, 2:end])

    if !any(typeof(rm) .<: (MDD, ADD, CDaR, EDaR, RDaR, UCI))
        risks .*= sqrt(t_factor)
    end

    sharpe = nothing
    if frontier[:sharpe]
        sharpe = risks[end]
    end

    idx = sortperm(risks)
    risks = risks[idx]
    weights = weights[:, idx]

    title = "$(get_rm_string(rm))"
    if any(typeof(rm) .<: (CVaR, TG, EVaR, RVaR, RCVaR, RTG, CDaR, EDaR, RDaR))
        title *= " α = $(round(rm.alpha*100, digits=2))%"
    end
    if any(typeof(rm) .<: (RCVaR, RTG))
        title *= ", β = $(round(rm.beta*100, digits=2))%"
    end
    if any(typeof(rm) .<: (RVaR, RDaR))
        title *= ", κ = $(round(rm.kappa, digits=2))"
    end

    f = Figure()
    ax = Axis(f[1, 1]; title = title, ylabel = "Composition", xlabel = "Expected Risk",
              limits = (minimum(risks), maximum(risks), 0, 1))

    N = length(risks)
    weights = cumsum(weights; dims = 1)
    colors = cgrad(palette, size(weights, 1))
    for i ∈ axes(weights, 1)
        if i == 1
            band!(ax, risks, range(0, 0, N), weights[i, :]; label = assets[i],
                  color = colors[i])
        else
            band!(ax, risks, weights[i - 1, :], weights[i, :]; label = assets[i],
                  color = colors[i])
        end
    end
    if !isnothing(sharpe)
        vlines!(ax, sharpe; ymin = 0.0, ymax = 1.0, color = :black, linewidth = 3)
        text!(ax, (sharpe * 1.1, 0.5); text = "Max Risk\nAdjusted\nReturn Ratio",
              align = (:left, :baseline))
    end
    axislegend(ax; position = :rc)
    return f
end
function PortfolioOptimiser.plot_frontier(port::AbstractPortfolio, key = nothing;
                                          t_factor = 252)
    if isnothing(key)
        key = get_rm_string(rm)
    end
    return PortfolioOptimiser.plot_frontier(port.frontier[key]; t_factor = t_factor)
end

function PortfolioOptimiser.plot_drawdown(timestamps::AbstractVector, w::AbstractVector,
                                          X::AbstractMatrix; alpha::Real = 0.05,
                                          kappa::Real = 0.3,
                                          solvers::Union{<:AbstractDict, Nothing} = nothing,
                                          palette = :Spectral)
    ret = X * w

    prices = copy(ret)
    pushfirst!(prices, 0)
    prices .+= 1
    prices = cumprod(prices)
    popfirst!(prices)
    prices2 = cumsum(copy(ret)) .+ 1

    dd = similar(prices2)
    peak = -Inf
    for i ∈ eachindex(prices2)
        if prices2[i] > peak
            peak = prices2[i]
        end
        dd[i] = prices2[i] - peak
    end

    dd .*= 100

    risks = [-PortfolioOptimiser._ADD_abs(ret), -PortfolioOptimiser._UCI_abs(ret),
             -PortfolioOptimiser._DaR_abs(ret, alpha),
             -PortfolioOptimiser._CDaR_abs(ret, alpha),
             -PortfolioOptimiser._EDaR_abs(ret, solvers, alpha),
             -PortfolioOptimiser._RDaR_abs(ret, solvers, alpha, kappa),
             -PortfolioOptimiser._MDD_abs(ret)] * 100

    conf = round((1 - alpha) * 100; digits = 2)

    risk_labels = ("Average Drawdown: $(round(risks[1], digits = 2))%",
                   "Ulcer Index: $(round(risks[2], digits = 2))%",
                   "$(conf)% Confidence DaR: $(round(risks[3], digits = 2))%",
                   "$(conf)% Confidence CDaR: $(round(risks[4], digits = 2))%",
                   "$(conf)% Confidence EDaR: $(round(risks[5], digits = 2))%",
                   "$(conf)% Confidence RDaR ($(round(kappa, digits=2))): $(round(risks[6], digits = 2))%",
                   "Maximum Drawdown: $(round(risks[7], digits = 2))%")

    colors = cgrad(palette)[length(risk_labels) + 1]
    return f
end
end
