using Test, PortfolioOptimiser, DataFrames, CSV, Dates, Clarabel, LinearAlgebra, Makie,
      TimeSeries

prices = TimeArray(CSV.File("./assets/stock_prices.csv"); timestamp = :date)

# using CairoMakie
# @testset "Plot returns" begin
portfolio = Portfolio2(; prices = prices,
                       solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                        :params => Dict("verbose" => false,
                                                                        "max_step_fraction" => 0.75))))
asset_statistics2!(portfolio)
rm = SD2()
obj = MinRisk()
w1 = optimise2!(portfolio; type = RP2(), rm = rm, kelly = AKelly(), obj = obj)

prp = plot_returns2(portfolio, :RP2)
pra = plot_returns2(portfolio, :RP2; per_asset = true)
pb = plot_bar2(portfolio, :RP2)
prc = plot_risk_contribution2(portfolio, :RP2; rm = rm, percentage = true)
fw = efficient_frontier!(portfolio; kelly = NoKelly(), rm = rm, points = 5)
pf = plot_frontier2(portfolio; kelly = NoKelly(), rm = rm)

fw = efficient_frontier!(portfolio; rm = rm, points = 5)
pf = plot_frontier2(portfolio; rm = rm)

pfa = plot_frontier_area2(fw; rm = rm, t_factor = 252)
# end

# using StatsPlots
# using GraphRecipes
# portfolio2 = Portfolio(; prices = prices,
#                        solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
#                                                         :params => Dict("verbose" => false,
#                                                                         "max_step_fraction" => 0.75))))
# asset_statistics!(portfolio2)
# rm = :SD
# obj = :Min_Risk
# fw2 = efficient_frontier!(portfolio2; points = 5)
# prc = plot_frontier_area(fw2)

# w = optimise!(portfolio2, OptimiseOpt(; type = :RP, rm = rm, obj = obj);
#               save_opt_params = true)
# plt1 = plot_risk_contribution(portfolio2; type = :RP, rm = rm, percentage = false)
# prp = plot_returns2(portfolio)
# pra = plot_returns2(portfolio; per_asset = true)
# pb = plot_bar2(portfolio)
# prc = plot_risk_contribution2(portfolio, :RP; rm = rm, percentage = true)
