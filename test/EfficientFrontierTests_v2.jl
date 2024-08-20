using CSV, TimeSeries, DataFrames, StatsBase, Statistics, LinearAlgebra, Test, Clarabel,
      PortfolioOptimiser

prices = TimeArray(CSV.File("./assets/stock_prices.csv"); timestamp = :date)
rf = 1.0329^(1 / 252) - 1
l = 2.0

@testset "Frontier limits" begin
    portfolio = Portfolio2(; prices = prices,
                           solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                            :params => Dict("verbose" => false,
                                                                            "max_step_fraction" => 0.75))))
    asset_statistics2!(portfolio)
    rm = [SD2(), [CVaR2()], [FLPM2(), FLPM2()]]

    limits = frontier_limits!(portfolio; rm = rm)
    w_min = optimise2!(portfolio; rm = rm, obj = MinRisk())
    w_max = optimise2!(portfolio; rm = rm, obj = MaxRet())

    @test isapprox(limits.w_min, w_min.weights)
    @test isapprox(limits.w_max, w_max.weights)

    rm = SD2()

    limits = frontier_limits!(portfolio; rm = rm)
    w_min = optimise2!(portfolio; rm = rm, obj = MinRisk())
    w_max = optimise2!(portfolio; rm = rm, obj = MaxRet())

    @test isapprox(limits.w_min, w_min.weights)
    @test isapprox(limits.w_max, w_max.weights)

    limits = efficient_frontier!(portfolio; rm = rm, points = 5, rf = rf)
    wt = reshape([0.007911813464316563, 0.030685102137465003, 0.010505366137937627,
                  0.02748375285330022, 0.012276170276064991, 0.033407270362069155,
                  3.9681916897466676e-7, 0.13984690156809362, 6.626902694299562e-7,
                  1.4125052278009859e-5, 0.287819278544025, 4.2200065479380485e-7,
                  3.2968647670955543e-7, 0.1252756033367362, 1.836077877893019e-6,
                  0.015083599354026141, 2.2788913848604495e-5, 0.19311714086149775,
                  8.33379655093792e-7, 0.11654660648423812, 5.522224699793474e-8,
                  8.595089733302895e-8, 1.1299211075867191e-7, 9.004418567193446e-8,
                  0.7603447997259856, 2.0857871299838532e-8, 0.10679798925701194,
                  5.31830792322655e-8, 1.125713192391737e-7, 5.123621024195307e-8,
                  4.899546767367109e-8, 1.9451754271548597e-8, 1.4085043859691273e-8,
                  3.108078841233075e-8, 1.3988792510981185e-8, 0.132855717795701,
                  4.4124543954595613e-7, 5.717461575369896e-8, 2.1497707198450864e-7,
                  7.016440669391734e-8, 1.4860311511999537e-8, 1.5860942169894057e-8,
                  2.060361671349228e-8, 1.851013414730744e-8, 0.47925439726009467,
                  7.3321493770373425e-9, 0.520745353619483, 1.086206907327974e-8,
                  1.689840348956604e-8, 1.1874459928861693e-8, 1.0581415190200713e-8,
                  7.637041918745811e-9, 5.732882111351544e-9, 9.035325076020031e-9,
                  5.945350090010823e-9, 2.8890103826025858e-8, 2.157382221912748e-8,
                  1.140811403288131e-8, 1.753205846463443e-8, 1.3982223083716686e-8,
                  3.6876566931205557e-8, 3.925078702660958e-8, 5.026786497330138e-8,
                  4.5349372825061764e-8, 0.22531675623035308, 1.79053266866814e-8,
                  0.7746826336360795, 2.7016549713215785e-8, 4.158911359968695e-8,
                  2.9504460952516377e-8, 2.6284085956563578e-8, 1.873414324876614e-8,
                  1.3874554199489658e-8, 2.2300382810794787e-8, 1.4382291311469858e-8,
                  6.801121363366443e-8, 5.248185684549183e-8, 2.83754251890722e-8,
                  4.31570057800522e-8, 3.4772565832482774e-8, 2.2425872064182503e-8,
                  2.3869345714744183e-8, 3.0249972071127925e-8, 2.7441036408966832e-8,
                  2.674016472879105e-6, 1.1117945427350462e-8, 0.9999969549278999,
                  1.6603745200809882e-8, 2.5223224538501096e-8, 1.8088400365786554e-8,
                  1.61723807198772e-8, 1.1616638624454757e-8, 8.681387036441865e-9,
                  1.377196283532058e-8, 8.992921448080973e-9, 4.0392434474846235e-8,
                  3.1600448886835504e-8, 1.7426103712222823e-8, 2.6166436896960802e-8,
                  2.1215370935214236e-8, 3.047582528418522e-9, 8.756567541674287e-9,
                  1.1835977214587516e-8, 7.037545568931999e-9, 0.5180580294593818,
                  8.497531385947768e-10, 0.06365095465210938, 7.0711477034951855e-9,
                  6.7939196887796965e-9, 3.406672092177662e-9, 5.600435093444268e-9,
                  7.439076222463269e-10, 5.560792252858543e-10, 1.6569788357809212e-9,
                  5.015125347530657e-10, 0.1432677879703678, 0.19649629723668446,
                  6.666401644796081e-9, 0.07852685909966116, 7.057315080480989e-9], 20, :)
    @test isapprox(Matrix(limits[:weights][!, 2:end]), wt)

    # portfolio2 = Portfolio(; prices = prices,
    #                        solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
    #                                                         :params => Dict("verbose" => false,
    #                                                                         "max_step_fraction" => 0.75))))
    # asset_statistics!(portfolio2)
    # returns = portfolio2.returns
    # sigma = portfolio2.cov
    # alpha_i = portfolio2.alpha_i
    # alpha = portfolio2.alpha
    # a_sim = portfolio2.a_sim
    # beta_i = portfolio2.beta_i
    # beta = portfolio2.beta
    # b_sim = portfolio2.b_sim
    # kappa = portfolio2.kappa
    # owa_w = portfolio2.owa_w
    # solvers = portfolio2.solvers

    # rm = :SD
    # opt = OptimiseOpt(; rf = rf, l = l, class = :Classic, hist = 1, type = :Trad,
    #                   rrp_ver = :None, u_mu = :None, u_cov = :None, rm = rm, obj = :Min_Risk,
    #                   kelly = :None)
    # w1 = optimise!(portfolio2, opt)
    # opt.obj = :Max_Ret
    # w2 = optimise!(portfolio2, opt)
    # opt.obj = :Sharpe
    # w3 = optimise!(portfolio2, opt)
    # fw1 = efficient_frontier!(portfolio2, opt; points = 5)
end