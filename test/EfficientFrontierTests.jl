using CSV, TimeSeries, DataFrames, StatsBase, Statistics, LinearAlgebra, Test, Clarabel,
      PortfolioOptimiser

path = joinpath(@__DIR__, "assets/stock_prices.csv")
prices = TimeArray(CSV.File(path); timestamp = :date)
rf = 1.0329^(1 / 252) - 1
l = 2.0

@testset "Frontier limits" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)
    rm = [SD(), [CVaR()], [FLPM(), FLPM()]]

    type = Trad(; rm = rm, obj = Sharpe())
    limits = frontier_limits!(portfolio, type)
    type.obj = MinRisk()
    w_min = optimise!(portfolio, type)
    type.obj = MaxRet()
    w_max = optimise!(portfolio, type)

    @test isapprox(limits.w_min, w_min.weights)
    @test isapprox(limits.w_max, w_max.weights)

    rm = SD()

    type = Trad(; rm = rm)
    limits = frontier_limits!(portfolio, type)
    type.obj = MinRisk()
    w_min = optimise!(portfolio, type)
    type.obj = MaxRet()
    w_max = optimise!(portfolio, type)

    @test isapprox(limits.w_min, w_min.weights)
    @test isapprox(limits.w_max, w_max.weights)

    frontier1 = efficient_frontier!(portfolio, type; points = 5, rf = rf)
    wt = reshape([0.007909507116557548, 0.030689815590971746, 0.010506820975926432,
                  0.027486829109498616, 0.012277542618295632, 0.033411420847851196,
                  1.7975271702520832e-8, 0.1398483275799478, 3.0152811334707373e-8,
                  6.402084049194017e-7, 0.2878222213859517, 1.9180117683673704e-8,
                  1.4940849408972136e-8, 0.12528331317956934, 8.317867073006387e-8,
                  0.015085386702998686, 1.0338450634362328e-6, 0.193123571148767,
                  3.793992564885321e-8, 0.11655336632254946, 5.522285649059127e-8,
                  8.595199651239285e-8, 1.1299357513754699e-7, 9.004528197162687e-8,
                  0.7603444030745325, 2.0858081600412657e-8, 0.106797897892116,
                  5.3183739541637516e-8, 1.1257285816871655e-7, 5.1236803896734674e-8,
                  4.8996064553226e-8, 1.945194126349173e-8, 1.4085177698817528e-8,
                  3.108112378114405e-8, 1.3988924376574408e-8, 0.13285620578502577,
                  4.4125802280019027e-7, 5.717533282320781e-8, 2.1498126912575396e-7,
                  7.016527603126866e-8, 1.4860305256160877e-8, 1.5860935523785307e-8,
                  2.060360819902164e-8, 1.8510126466784517e-8, 0.47925450451070845,
                  7.332146319019305e-9, 0.5207452463689725, 1.0862064488668788e-8,
                  1.689839646410145e-8, 1.1874454926955542e-8, 1.0581410727036427e-8,
                  7.637038721223906e-9, 5.732879734641738e-9, 9.035321280419992e-9,
                  5.945347625429742e-9, 2.8890092460046426e-8, 2.157381335374888e-8,
                  1.140810921900157e-8, 1.7532051178385884e-8, 1.3982217192047051e-8,
                  3.687655967283613e-8, 3.9250779311428575e-8, 5.026785518080705e-8,
                  4.5349363965916825e-8, 0.22531680018754752, 1.790532320818163e-8,
                  0.7746825896790039, 2.7016544392291355e-8, 4.1589105447263777e-8,
                  2.9504455141551167e-8, 2.628408078512137e-8, 1.8734139596761488e-8,
                  1.387455152239359e-8, 2.2300378443735583e-8, 1.4382288537181559e-8,
                  6.801120065288931e-8, 5.248184663610968e-8, 2.8375419599442526e-8,
                  4.315699731964545e-8, 3.477255897895294e-8, 2.2425872064182503e-8,
                  2.3869345714744183e-8, 3.0249972071127925e-8, 2.7441036408966832e-8,
                  2.674016472879105e-6, 1.1117945427350462e-8, 0.9999969549278999,
                  1.6603745200809882e-8, 2.5223224538501096e-8, 1.8088400365786554e-8,
                  1.61723807198772e-8, 1.1616638624454757e-8, 8.681387036441865e-9,
                  1.377196283532058e-8, 8.992921448080973e-9, 4.0392434474846235e-8,
                  3.1600448886835504e-8, 1.7426103712222823e-8, 2.6166436896960802e-8,
                  2.1215370935214236e-8, 1.0296845450132623e-8, 3.021952640815953e-8,
                  4.1214766461007244e-8, 2.4243263954257325e-8, 0.5180577658534262,
                  3.0943996622610983e-9, 0.06365090147010465, 2.4313177563254918e-8,
                  2.3863972112732305e-8, 1.169573373834161e-8, 1.906927615395326e-8,
                  2.6885468847139513e-9, 1.995833183461601e-9, 5.6450161227892134e-9,
                  1.944577491513239e-9, 0.14326786015143234, 0.19649710519195163,
                  2.2816180558950185e-8, 0.07852611996592547, 2.426604399445612e-8], 20, :)
    @test isapprox(Matrix(frontier1[:weights][!, 2:end]), wt)

    wt = reshape([0.007909394729268278, 0.030690031456872584, 0.010506888898099044,
                  0.027486968345041597, 0.012277609956471378, 0.03341161180109064,
                  1.323781083918104e-9, 0.1398483916179671, 2.291047864946532e-9,
                  3.6572867111228674e-8, 0.2878223523344577, 1.52989153786824e-9,
                  1.181044715105426e-9, 0.12528365238381148, 6.016585823556773e-9,
                  0.015085469019209397, 5.660199301875489e-8, 0.193123858123687,
                  2.888310326964356e-9, 0.11655366292850229, 1.041669325602768e-8,
                  4.3317182854182e-7, 1.3288920530350866e-6, 8.571332771167551e-8,
                  0.30559593417129466, 2.9622941203741676e-9, 0.03015251360641987,
                  0.07142919097829747, 1.2634670215036934e-8, 1.2275039349286197e-8,
                  0.11870114361526896, 1.7290181839131632e-9, 1.2681017673441843e-9,
                  6.3833434720219826e-9, 1.3234594172288643e-9, 0.0982483564669195,
                  0.1941246365274598, 0.07252631057085214, 0.09661493813735562,
                  0.012605079156302912, 1.0012648986398347e-8, 3.511877716514275e-8,
                  4.550374219509118e-8, 2.369054042953939e-8, 0.461251911983998,
                  3.0750722821350632e-9, 0.05336125539024205, 6.187949507509943e-8,
                  1.6451626324598276e-8, 1.0714004735223522e-8, 3.473645060619358e-8,
                  2.1903109772776372e-9, 1.6088530192079228e-9, 5.524926810026879e-9,
                  1.569885204680518e-9, 0.13742597541525378, 0.22994625856661463,
                  3.782135530122393e-8, 0.11801427905299251, 2.9693209871116176e-8,
                  3.811661544703151e-9, 6.963811789113534e-9, 9.034866053644113e-9,
                  6.687521293747189e-9, 0.6874089047044809, 1.3125038554468875e-9,
                  0.0927727472358781, 4.249616646097679e-9, 9.508244512668183e-9,
                  3.5702247384925925e-9, 3.757886437105591e-9, 1.089316855193812e-9,
                  7.776116820008926e-10, 2.0356726702481484e-9, 7.616541732812044e-10,
                  0.1550278651633079, 0.06479037166454016, 4.616501873750707e-9,
                  4.7685627169169914e-8, 5.3690717226579565e-9, 2.6448730799543275e-9,
                  2.84136407921336e-9, 3.522895866005757e-9, 3.173029043321613e-9,
                  0.8533950733241444, 1.2212191075632512e-9, 0.1466048825059837,
                  1.9079993932701713e-9, 3.028621888738376e-9, 2.006910120031864e-9,
                  1.7998471634803133e-9, 1.1638763753787592e-9, 8.445384798942713e-10,
                  1.4971269872145801e-9, 8.53684515570025e-10, 6.0777608650998104e-9,
                  3.916392054196438e-9, 2.0275785532387972e-9, 3.23260743019179e-9,
                  2.4095469351237304e-9, 1.026855832377015e-8, 3.2139097529224765e-8,
                  4.1856314419920304e-8, 2.3600679221681593e-8, 0.4894179639360829,
                  3.230971832847484e-9, 0.05833720025769615, 3.3199118937348626e-8,
                  2.116837720240594e-8, 1.1529085913907569e-8, 2.424939577704955e-8,
                  2.628707801353928e-9, 1.9131084660782398e-9, 5.84251969297182e-9,
                  1.8637737926838568e-9, 0.1403269734754189, 0.213377177297938,
                  2.8301813554462742e-8, 0.09854041682213821, 2.6419203527148663e-8], 20, :)
    frontier2 = efficient_frontier!(portfolio, Trad(; kelly = EKelly(), rm = SD());
                                    points = 5, rf = rf)
    @test isapprox(Matrix(frontier2[:weights][!, 2:end]), wt, rtol = 5.0e-6)
end
