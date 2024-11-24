using CSV, TimeSeries, DataFrames, StatsBase, Statistics, LinearAlgebra, Test, Clarabel,
      PortfolioOptimiser

path = joinpath(@__DIR__, "assets/stock_prices.csv")
prices = TimeArray(CSV.File(path); timestamp = :date)
rf = 1.0329^(1 / 252) - 1
l = 2.0

@testset "Variance" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = Variance()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)
    rc3 = risk_contribution(portfolio; type = :RP, rm = Variance())
    lrc3, hrc3 = extrema(rc3)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)
    rc4 = risk_contribution(portfolio; type = :RP, rm = Variance())
    lrc4, hrc4 = extrema(rc4)

    w1t = [0.05063484430993387, 0.051248247145833405, 0.04690544758235205,
           0.04368810360104776, 0.04571303450312897, 0.05614653791155684,
           0.02763256689699135, 0.07706277240162171, 0.039493544309350315,
           0.04723302139657694, 0.08434815328832226, 0.033857024708878705,
           0.027547931971505683, 0.0620621872517023, 0.03563793172255409,
           0.04413334025063814, 0.050849763453794807, 0.07142385153127292,
           0.04529955435624263, 0.05908214140669532]
    w2t = [0.005639940543949097, 0.011009340035755901, 0.015582497207404294,
           0.019370512771987466, 0.025438318732809228, 0.03265843055798135,
           0.02037186992290285, 0.05956750307617451, 0.03298314558343289,
           0.044829563191341355, 0.08741264482620345, 0.03822710208900545,
           0.031439207649716396, 0.0796055307252523, 0.046144090275857204,
           0.06097561787250882, 0.08329103566856179, 0.11639034674107102,
           0.07928340577792381, 0.10977989675016077]
    @test isapprox(w1.weights, w1t, rtol = 0.0001)
    @test isapprox(w2.weights, w2t, rtol = 0.0001)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.0005)
    @test isapprox(hrc2 / lrc2, 20, rtol = 5.0e-4)
    @test isapprox(hrc3 / lrc3, hrc1 / lrc1, rtol = 5.0e-10)
    @test isapprox(hrc4 / lrc4, hrc2 / lrc2, rtol = 5.0e-10)

    portfolio.risk_budget = fill(inv(20), 20)
    portfolio.risk_budget[1] = 5
    w3 = optimise!(portfolio; type = RP())
    rc3 = risk_contribution(portfolio; type = :RP)
    lrc5, hrc5 = extrema(rc3)
    @test isapprox(hrc5 / lrc5, 100, rtol = 0.0005)
end

@testset "MAD" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = MAD()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.05616718884171783, 0.05104482287669086, 0.050442185055943126,
           0.04081085987206851, 0.048790821392722006, 0.056713242149170624,
           0.024225418284767215, 0.07090469906463681, 0.04019545588230386,
           0.046489535418913604, 0.08138390797380332, 0.03158855211640958,
           0.023961449523877854, 0.062252124307186275, 0.034592269087233674,
           0.04206365189343823, 0.05465542813736888, 0.07239054942796913,
           0.04770615320793009, 0.06362168548584848]
    w2t = [0.0063961952250897024, 0.01259233570812754, 0.01733507546160919,
           0.019133369264133202, 0.028375436997384727, 0.031889180424327784,
           0.019206369765627646, 0.055400873920331425, 0.03337728881511272,
           0.045145056375019046, 0.08075326190057375, 0.03493485143072039,
           0.02578004094261155, 0.07995311292670913, 0.044767477387302204,
           0.05590147350787757, 0.0922934334228999, 0.12029607659061349,
           0.08192688910102709, 0.11454220083290197]
    @test isapprox(w1.weights, w1t, rtol = 5.0e-5)
    @test isapprox(w2.weights, w2t, rtol = 5.0e-7)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.01)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.005)
end

@testset "SSD" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = SSD()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.05053927750227942, 0.05271325589318637, 0.04504106160525596,
           0.04044991084891684, 0.045697350554167335, 0.05416177290339106,
           0.026499490793228032, 0.07776583172257508, 0.038243904391379806,
           0.044545474025866234, 0.08432742630193225, 0.03546280957236507,
           0.02992913805074365, 0.06261843327177671, 0.03923880111295301,
           0.04565294332231343, 0.04985063996037994, 0.07413165623546289,
           0.044276510952126515, 0.05885431097970036]
    w2t = [0.005428687871925218, 0.011165997744344677, 0.014457877462411622,
           0.017041104189619228, 0.024073101414898677, 0.03133995492451869,
           0.019075804783727716, 0.05919921912726392, 0.03194488914093804,
           0.04195795744473274, 0.08814684328464706, 0.038997168516058264,
           0.03418175861909682, 0.07927633692959091, 0.05026058595905142,
           0.06339052851645095, 0.08186275704784614, 0.12155956696235388,
           0.07827595148631002, 0.10836390857421406]
    @test isapprox(w1.weights, w1t, rtol = 0.0001)
    @test isapprox(w2.weights, w2t, rtol = 1.0e-5)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.0005)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.0005)
end

@testset "FLPM" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = FLPM()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.054267057099694184, 0.05096246113557045, 0.05095255097020979,
           0.040032406904224854, 0.0556874290889964, 0.048539424291517114,
           0.024657999063861406, 0.07062985573445954, 0.04179091294583214,
           0.04606660805022222, 0.08265241772134334, 0.027989026643651344,
           0.02190437066256167, 0.059099626838259325, 0.03013382433142087,
           0.045279133438256215, 0.057925748682471315, 0.07483177363752329,
           0.04995819759930101, 0.06663917516062365]
    w2t = [0.006878868232648054, 0.012951149393094247, 0.018381735576801738,
           0.01831469262744488, 0.03608453233241397, 0.02719604369495882,
           0.020207074438070734, 0.052774398319475106, 0.033761212787344494,
           0.04423765658397453, 0.08235670938100217, 0.031749539125101554,
           0.024157585599707543, 0.07391869180768487, 0.03806447452897265,
           0.05744778736381905, 0.0995482799675567, 0.12220053760565629,
           0.08483102562198958, 0.11493800501228298]
    @test isapprox(w1.weights, w1t, rtol = 1.0e-5)
    @test isapprox(w2.weights, w2t, rtol = 5.0e-6)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.005)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.0005)
end

@testset "SLPM" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = SLPM()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.05078127940733007, 0.053709289520370206, 0.045765499111031845,
           0.04092124166773404, 0.04906350161785088, 0.05034642655205059,
           0.027363313590193325, 0.07790700226241161, 0.03854385546416795,
           0.04420307984253257, 0.08430309761074495, 0.03395810327214033,
           0.028244948471502513, 0.06056629784190088, 0.036508496019863564,
           0.04757367293185978, 0.051284241663104566, 0.07441627002609454,
           0.04500824504878194, 0.05953213807833387]
    w2t = [0.0054916073854252906, 0.011427939296813336, 0.01482057459914487,
           0.017304371379962005, 0.02632048335008413, 0.029055266030112614,
           0.019768193133877558, 0.05921585232078186, 0.03219069820365385,
           0.04164854622777103, 0.08829470628803716, 0.037308239885460066,
           0.03234413972831064, 0.07667318635649392, 0.047034271680223304,
           0.06579073258270003, 0.08444743344829933, 0.12166293164184272,
           0.07958310033100874, 0.10961772612999747]
    @test isapprox(w1.weights, w1t, rtol = 5.0e-5)
    @test isapprox(w2.weights, w2t, rtol = 1.0e-5)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.0005)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.0005)
end

@testset "WR" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = WR()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.043757321581810414, 0.0822733742327415, 0.0436602082667364,
           0.05731637956632544, 0.05518253405854848, 0.04887765289594206,
           0.0364595791033413, 0.04988408327420239, 0.03936409791792019,
           0.04856653979941317, 0.057383681235270545, 0.03890836447870425,
           0.04249964923744369, 0.037820589663936664, 0.04825224579857682,
           0.0498858692877157, 0.06042687519019553, 0.041036573681297046,
           0.04176201475980447, 0.07668236597007388]
    w2t = [0.004526237015894095, 0.015997474101203387, 0.012811159745908298,
           0.022465579875522047, 0.0223177318630974, 0.031293081065040196,
           0.03122893846568954, 0.03943675894118864, 0.03480951552918271,
           0.04185179466637399, 0.0642910409340559, 0.04586248994132221,
           0.06078494786595186, 0.053510801546698204, 0.059734683261052406,
           0.0842140882259648, 0.10213656258967437, 0.07536518051497272, 0.0755840036469502,
           0.12177793020425705]
    @test isapprox(w1.weights, w1t, rtol = 0.0001)
    @test isapprox(w2.weights, w2t, rtol = 0.0001)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.5)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.05)
end

@testset "RG" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = RG()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.03141997465637757, 0.04977499477148719, 0.04187114359583626,
           0.1092709746839547, 0.040302360122874074, 0.05222655887333725,
           0.03836754735185509, 0.059024793482223635, 0.03891494867941388,
           0.062412354481534905, 0.06227647865499888, 0.04249051606921931,
           0.04679875326560747, 0.036572659740749996, 0.06496218226285785,
           0.035641383527722635, 0.04490696424109597, 0.04669575503705878,
           0.04181298570349804, 0.05425667079829651]
    w2t = [0.0032115713459440046, 0.009789161740529536, 0.012410176155093962,
           0.04353604278840679, 0.017522665838650267, 0.03363737795829702,
           0.03265130856300981, 0.04722460921723296, 0.03475641617373519,
           0.05355268209414306, 0.0704215644082256, 0.05062517817133151,
           0.06746841990954869, 0.05203665550590438, 0.07902655645047767,
           0.058989794563634054, 0.07616307748262995, 0.08674498093786183,
           0.07669598830894978, 0.0935357723863939]
    @test isapprox(w1.weights, w1t, rtol = 5.0e-5)
    @test isapprox(w2.weights, w2t, rtol = 5.0e-5)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.0005)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.05)
end

@testset "CVaR" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = CVaR()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.049387129895525614, 0.04880041958645412, 0.0417360796429531,
           0.03840901174332172, 0.04184139932560737, 0.053780063457719865,
           0.026424802585162756, 0.0773672149813708, 0.03544241306631173,
           0.04094196008260876, 0.09252539697406174, 0.042683400449354016,
           0.03238760400585853, 0.06577416488603098, 0.040197811307927274,
           0.04220372473527037, 0.0487231801118939, 0.08071251851657814,
           0.04276785407281033, 0.05789385057317895]
    w2t = [0.004959275431282591, 0.01072383905357794, 0.013513620630296753,
           0.015940869351360548, 0.022147199451113472, 0.029231288868935196,
           0.01915525408328189, 0.06220264996323651, 0.02958232963526513,
           0.04035125157487067, 0.09432575711856797, 0.04011270316987755,
           0.03579812150408999, 0.07561013938464527, 0.05081122017831414,
           0.06895063432028874, 0.07714489801105029, 0.12899675704367752,
           0.07491058752088728, 0.10553160370538055]
    @test isapprox(w1.weights, w1t, rtol = 5.0e-5)
    @test isapprox(w2.weights, w2t, rtol = 5.0e-5)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.1)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.005)
end

@testset "CVaRRG" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = CVaRRG()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.050269049067239474, 0.0477841693631293, 0.04260280490906643,
           0.04203989184309871, 0.043925216463068635, 0.05759771772474327,
           0.02942674977284078, 0.07979471443162556, 0.03759416396809604,
           0.04513299513579427, 0.08755599134650839, 0.035814547787941235,
           0.030137053397101272, 0.0664242038465082, 0.03710802437521975,
           0.042448048833865756, 0.04778877261428286, 0.07555923590950067,
           0.04385507971795442, 0.057141569492415]
    w2t = [0.00523446044745023, 0.010280825090916797, 0.014110076080297226,
           0.01900495090158587, 0.024059105238347697, 0.03235151230331019,
           0.0233106211797784, 0.060931395967118704, 0.03251551988754096,
           0.04493317236108299, 0.09081297707962498, 0.038901614588372845,
           0.03465074756319317, 0.08231959509767278, 0.04604470994032463,
           0.05819037345801733, 0.08044369521443982, 0.12044775361725577,
           0.07810426536665324, 0.10335262861701634]
    @test isapprox(w1.weights, w1t, rtol = 5.0e-5)
    @test isapprox(w2.weights, w2t, rtol = 5.0e-5)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.05)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.005)
end

@testset "EVaR" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = EVaR()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.046441175139679075, 0.0636635926954678, 0.0437905327100388,
           0.05092290582010278, 0.0464093742619314, 0.05061665593049196,
           0.03894587929172149, 0.0658674606383409, 0.03842120337585926,
           0.044461528797653645, 0.06810063277922151, 0.04257098857986524,
           0.04132606801031959, 0.049160675556679065, 0.04438749327363125,
           0.053443618688456575, 0.05369210088508193, 0.05226821690404457,
           0.04178234191426879, 0.06372755474714445]
    w2t = [0.004649064633994313, 0.013024128816592357, 0.013065166884888157,
           0.020518113549704037, 0.022282631649315945, 0.030139092451586413,
           0.02817712722231638, 0.04961150619044857, 0.0332088114654529,
           0.04172011248113971, 0.07294398194510515, 0.04732479787078266,
           0.051090244842984446, 0.06410260111407641, 0.05751225215578386,
           0.07959987570465571, 0.08923067053518313, 0.08897533037236685,
           0.0757163816109926, 0.11710810850263045]
    @test isapprox(w1.weights, w1t, rtol = 1.0e-5)
    @test isapprox(w2.weights, w2t, rtol = 5.0e-6)
    @test isapprox(hrc1 / lrc1, 1, rtol = 1)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.001)
end

@testset "RLVaR" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = RLVaR()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)

    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.04549546983882415, 0.07569593834645903, 0.04395756946422178,
           0.05586720104955235, 0.049249589645283996, 0.05066244210696011,
           0.04110802259927475, 0.05449490114189938, 0.03937873998654336,
           0.04560091706356088, 0.06132309022695701, 0.040707768756211224,
           0.04367167227924062, 0.04184372389838059, 0.04509954105105621,
           0.05279627454932386, 0.05840797375507491, 0.044739545949107506,
           0.04159936492787433, 0.06830025336419407]
    w2t = [0.004579088865446104, 0.015157441585595907, 0.012920956868085615,
           0.02204271083803428, 0.02225228792164047, 0.031006238396748376,
           0.031024000145675426, 0.04188787193662531, 0.03446525431216618,
           0.04173270075705968, 0.06662190460862863, 0.04653340500195975,
           0.05758114832301181, 0.05644207642929947, 0.05881230870768455,
           0.08358010623093536, 0.09852182150757373, 0.07880031046381987,
           0.07568030175285387, 0.12035806534715568]
    @test isapprox(w1.weights, w1t, rtol = 1.0e-6)
    @test isapprox(w2.weights, w2t, rtol = 5.0e-7)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.25)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.25)
end

@testset "EVaR < RLVaR < WR" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = RLVaR(; kappa = 5e-3)
    w1 = optimise!(portfolio; rm = rm, type = RP())
    rm = RLVaR(; kappa = 1 - 5e-3)
    w2 = optimise!(portfolio; rm = rm, type = RP())
    rm = EVaR()
    w3 = optimise!(portfolio; rm = rm, type = RP())
    rm = WR()
    w4 = optimise!(portfolio; rm = rm, type = RP())

    if !Sys.isapple()
        @test isapprox(w1.weights, w3.weights, rtol = 0.01)
    end
    @test isapprox(w2.weights, w4.weights, rtol = 1.0e-4)
end

@testset "MDD" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = MDD()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = reverse(1:size(portfolio.returns, 2))
    w2 = optimise!(portfolio; type = RP(), rm = rm)

    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.0832226755172904, 0.03469976232870371, 0.04178756401104356,
           0.027626625273967375, 0.03998306307780897, 0.05672636461843297,
           0.022342457038002583, 0.09418082088656306, 0.027866153990116427,
           0.0355838714778347, 0.15689409933603563, 0.03203159839417066,
           0.03750630444641577, 0.0399766484092098, 0.024305618157569323,
           0.04053983167664855, 0.04468902801560564, 0.06511478398457014,
           0.03540432378926396, 0.05951840557074665]
    w2t = [0.10305137382242804, 0.06581236519112994, 0.0709894827098822,
           0.048241621907253764, 0.06732850187701794, 0.06933295815596083,
           0.025148756820695124, 0.12492370497852971, 0.03239967250505383,
           0.04506726094560067, 0.1364819458861486, 0.03840359462378298,
           0.035802405548559145, 0.03527540849139431, 0.025258125662223532,
           0.02468672266208908, 0.01652174063302115, 0.021628355205884367,
           0.006760316427956624, 0.006885685945388183]
    @test isapprox(w1.weights, w1t, rtol = 1.0e-4)
    @test isapprox(w2.weights, w2t, rtol = 5.0e-5)
    @test isapprox(hrc1 / lrc1, 1, rtol = 1.0)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.25)
end

@testset "ADD" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = ADD()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.057606462854449564, 0.048757147583333986, 0.08760313404798067,
           0.028072171525899435, 0.06562456116627945, 0.042031866410813794,
           0.025691993374733636, 0.08529724954646445, 0.034594908564242806,
           0.035096572544019884, 0.10006902786342632, 0.02720565515290973,
           0.017629230206665174, 0.0396434223439632, 0.014602246134429559,
           0.04741538864525304, 0.07494445784801652, 0.04972287802730784,
           0.05842615813453437, 0.05996546802527647]
    w2t = [0.01117366781007166, 0.014033169054553924, 0.045908571107162684,
           0.012856587763064538, 0.050622843054460215, 0.022249776126497384,
           0.01862763478098223, 0.07977869361256462, 0.02874816697896668,
           0.031322680707860255, 0.1105249907447127, 0.02476816915865819,
           0.01688562364522229, 0.05345524384387573, 0.0195961710270235,
           0.061298883594235444, 0.12257905778456897, 0.07478548505959613,
           0.09193002828020275, 0.1088545558657202]
    @test isapprox(w1.weights, w1t, rtol = 0.0001)
    @test isapprox(w2.weights, w2t, rtol = 5.0e-5)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.5)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.1)
end

@testset "UCI" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = UCI()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.05482939977507546, 0.04136703344901281, 0.06164889652883999,
           0.0268478981008432, 0.05953795769080776, 0.03570199764806931,
           0.023355956562433257, 0.09683142130483709, 0.029808958230973952,
           0.032207590276252904, 0.1475999290522447, 0.03543126645976918,
           0.019399450744000575, 0.0419678790372104, 0.01724347555324004,
           0.049645575416911995, 0.06572971097464801, 0.0539484127566746,
           0.046251119404740554, 0.06064607103341418]
    w2t = [0.008154286578153593, 0.008781190376849138, 0.023209195001104903,
           0.011185790713888158, 0.039775349087535154, 0.02070829609129032,
           0.01831077163888364, 0.09098444685646642, 0.02501429263455831,
           0.028901383716111687, 0.17118200009515813, 0.03039066156086129,
           0.018933548234311447, 0.052984908028786755, 0.02121400841973578,
           0.05901915302335803, 0.10465913823759998, 0.08144615071936157,
           0.07867096408121685, 0.1064744649047689]
    @test isapprox(w1.weights, w1t, rtol = 5.0e-5)
    @test isapprox(w2.weights, w2t, rtol = 5.0e-5)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.5)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.5)
end

@testset "CDaR" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = CDaR()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.046950955979794685, 0.03661874760554526, 0.038223988588657366,
           0.027780516550856046, 0.05445110680774062, 0.034214753641007754,
           0.02235457818855092, 0.0891440899355276, 0.02730742650497644,
           0.028300548271497156, 0.2157867803618873, 0.040306880430063904,
           0.020910697807736522, 0.04004945288518099, 0.026363565986111177,
           0.044699572145195474, 0.058863654906891535, 0.04952002372532478,
           0.03914800563209636, 0.059004654045358026]
    w2t = [0.007053190526800975, 0.005446128277036701, 0.01241372313810428,
           0.009360737063492953, 0.04021058700684525, 0.019329177838430734,
           0.017749230999518865, 0.0871761904766593, 0.02200444636139792,
           0.02240084358896396, 0.25167513373016165, 0.035191371847968535,
           0.017720999126723272, 0.04550428705896632, 0.023422306961792816,
           0.047532660293921586, 0.08639815267463893, 0.07370795016486553,
           0.06435839366448634, 0.11134448919922418]
    @test isapprox(w1.weights, w1t, rtol = 5.0e-5)
    @test isapprox(w2.weights, w2t, rtol = 5.0e-5)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.1)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.1)
end

@testset "EDaR" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = EDaR()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.05532235699581659, 0.035788140800455205, 0.0407753569587081,
           0.0296057134575646, 0.04696905711931078, 0.040842428659498574,
           0.025301130647021896, 0.08891722046323698, 0.026897229105847707,
           0.03134376238119591, 0.19602182683257213, 0.039031614098305384,
           0.02653355216997208, 0.04068455054688783, 0.025037256367833247,
           0.04705215245370184, 0.053526293400258725, 0.05549120103462624,
           0.038350797642177206, 0.05650835886500902]
    w2t = [0.01585774887523436, 0.005700098123506493, 0.0154093602284636,
           0.009983988990045487, 0.03722637744745142, 0.024786173385869047,
           0.01694269985327135, 0.08449421949038945, 0.022634747150362334,
           0.02448621067406314, 0.21325707882221914, 0.0379160512807431,
           0.02305658860774649, 0.050538403993677206, 0.02457864267628073,
           0.05223382605008592, 0.0767149101174364, 0.08785359264768017,
           0.06349501181374491, 0.11283426977172926]
    @test isapprox(w1.weights, w1t, rtol = 1.0e-5)
    @test isapprox(w2.weights, w2t, rtol = 5.0e-5)
    @test isapprox(hrc1 / lrc1, 1, rtol = 1)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.5)
end

@testset "RLDaR" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = RLDaR()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.06793604284871738, 0.03531368372759915, 0.042023447287659055,
           0.03066508748365364, 0.04581748536071042, 0.046948060881784846,
           0.02581516857259885, 0.09117724220316131, 0.027341611754088595,
           0.032915284784924004, 0.1719331375051792, 0.035684217087994255,
           0.03230472152975499, 0.040188093229804094, 0.024627782457110628,
           0.04706524651000926, 0.04992592584769779, 0.058467051247865144,
           0.03735764770349489, 0.05649306197619242]
    w2t = [0.028296793376123033, 0.0057954596703316125, 0.015516214439508205,
           0.010367412960827622, 0.03458952805098015, 0.028785986871447945,
           0.016410413398176137, 0.08004481670997543, 0.02328148278668714,
           0.025784328928895758, 0.19331586412233384, 0.036797709769958775,
           0.028435126242073838, 0.05165442037924009, 0.025444557800996536,
           0.05270946166132721, 0.07210152030425954, 0.0951607562521504,
           0.06257871598828463, 0.11292943028642197]
    @test isapprox(w1.weights, w1t, rtol = 5.0e-7)
    @test isapprox(w2.weights, w2t, rtol = 5.0e-7)
    @test isapprox(hrc1 / lrc1, 1, rtol = 1.0)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.25)
end

@testset "EDaR < RLDaR < MDD" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75,
                                                                               "max_iter" => 300))))
    asset_statistics!(portfolio)

    rm = RLDaR(; kappa = 5e-3)
    w1 = optimise!(portfolio; rm = rm, type = RP())
    rm = RLDaR(; kappa = 1 - 5e-3)
    w2 = optimise!(portfolio; rm = rm, type = RP())
    rm = EDaR()
    w3 = optimise!(portfolio; rm = rm, type = RP())
    rm = MDD()
    w4 = optimise!(portfolio; rm = rm, type = RP())

    if !Sys.isapple()
        @test isapprox(w1.weights, w3.weights, rtol = 0.005)
    end
    @test isapprox(w2.weights, w4.weights, rtol = 1.0e-4)
end

@testset "Full Kurt" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = Kurt()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm, str_names = true)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.04622318966891087, 0.051735402412157364, 0.04439927739035058,
           0.05069294216523759, 0.04288956595183918, 0.055104528892227646,
           0.03376709775539053, 0.07877864366411548, 0.03912232452046387,
           0.04820386910393024, 0.07988980034322672, 0.03936329259230218,
           0.03430246703525708, 0.05650251786220336, 0.03863330880463875,
           0.04679014012154553, 0.04922989941972541, 0.0649897843888456,
           0.04344769695204487, 0.0559342509555872]
    w2t = [0.004745115300960629, 0.010553833683548, 0.014134891071172148,
           0.021525684594252546, 0.022377607814903267, 0.03218360364696926,
           0.02458565588014059, 0.0603388597300125, 0.03328288452785557,
           0.046497049074399444, 0.08453681188796948, 0.044939300192438816,
           0.040214301017160343, 0.07351675090554316, 0.05047459462089849,
           0.06588331054429225, 0.07959979719339691, 0.10842127106776223,
           0.07730932876018444, 0.10487934848613988]
    @test isapprox(w1.weights, w1t, rtol = 0.0001)
    @test isapprox(w2.weights, w2t, rtol = 0.0001)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.0005)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.0005)
end

@testset "Reduced Kurt" begin
    portfolio = OmniPortfolio(; prices = prices, max_num_assets_kurt = 1,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = Kurt()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.04591842179640149, 0.05179805405164705, 0.04434107746789892,
           0.05073576269255856, 0.04281559309978754, 0.05502400846984758,
           0.033702328915667525, 0.07909071247102473, 0.039084828143279446,
           0.04806917872417939, 0.08049384816589035, 0.03924991745050765,
           0.03422848311786619, 0.056402294323495306, 0.038571074160980434,
           0.04674744638239155, 0.049215020736204144, 0.06499655559593155,
           0.04336580052064711, 0.056149593713793446]
    w2t = [0.004657405843011066, 0.010507218482203191, 0.014020919525534851,
           0.021479156702709834, 0.02218399792303029, 0.031888811326582174,
           0.02449055152562633, 0.060262708467851894, 0.03309109723079836,
           0.04623393516867988, 0.08497008994914156, 0.04461965191283875,
           0.04008280382773206, 0.07302946835465755, 0.05022092884857667,
           0.06566591797487605, 0.07988614830630822, 0.10945172225056968,
           0.07703881166353045, 0.10621865471574114]
    @test isapprox(w1.weights, w1t, rtol = 0.0005)
    @test isapprox(w2.weights, w2t, rtol = 5.0e-5)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.05)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.05)
end

@testset "Full SKurt" begin
    portfolio = OmniPortfolio(; prices = prices, max_num_assets_kurt = 1,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = SKurt()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.047491170526917106, 0.054533530611338095, 0.04332743262413755,
           0.04409183402669535, 0.04294281900935894, 0.05479618527188426,
           0.029939286967814335, 0.07378407854092589, 0.038545585072875525,
           0.04491050797340899, 0.07820933163981073, 0.041819191428891594,
           0.03694060939399915, 0.05883380726473094, 0.04119066420625541,
           0.04894563617272387, 0.050636793381874066, 0.06522417318082553,
           0.04376830962159429, 0.0600690530839385]
    w2t = [0.004722364440696089, 0.010992860721782998, 0.013079608839292163,
           0.017758736836310487, 0.021164674109437814, 0.03180141478695387,
           0.020973561620900274, 0.05554877124015805, 0.03254270854952545,
           0.04234068577215489, 0.08231619106830286, 0.04515053000811545,
           0.043550361087069216, 0.07523952480527651, 0.05365405151585021,
           0.07059894578965538, 0.08206008823639577, 0.10767232222543825,
           0.07790990249926266, 0.11092269584742165]
    @test isapprox(w1.weights, w1t, rtol = 0.0005)
    @test isapprox(w2.weights, w2t, rtol = 1.0e-5)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.25)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.01)
end

@testset "Reduced SKurt" begin
    portfolio = OmniPortfolio(; prices = prices, max_num_assets_kurt = 1,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = SKurt()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.047491170526917106, 0.054533530611338095, 0.04332743262413755,
           0.04409183402669535, 0.04294281900935894, 0.05479618527188426,
           0.029939286967814335, 0.07378407854092589, 0.038545585072875525,
           0.04491050797340899, 0.07820933163981073, 0.041819191428891594,
           0.03694060939399915, 0.05883380726473094, 0.04119066420625541,
           0.04894563617272387, 0.050636793381874066, 0.06522417318082553,
           0.04376830962159429, 0.0600690530839385]
    w2t = [0.004722364440696089, 0.010992860721782998, 0.013079608839292163,
           0.017758736836310487, 0.021164674109437814, 0.03180141478695387,
           0.020973561620900274, 0.05554877124015805, 0.03254270854952545,
           0.04234068577215489, 0.08231619106830286, 0.04515053000811545,
           0.043550361087069216, 0.07523952480527651, 0.05365405151585021,
           0.07059894578965538, 0.08206008823639577, 0.10767232222543825,
           0.07790990249926266, 0.11092269584742165]
    @test isapprox(w1.weights, w1t, rtol = 0.0005)
    @test isapprox(w2.weights, w2t, rtol = 1.0e-5)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.25)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.01)
end

@testset "Skew" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = Skew()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.045906163224644574, 0.07415998382980167, 0.03239607344992543,
           0.02966142881533359, 0.047744535194566035, 0.035263473934568405,
           0.021314660518944012, 0.08112886966347481, 0.028882290213778045,
           0.030719886281928503, 0.06276040888349436, 0.047499913461799256,
           0.04347953183392477, 0.052066756947510194, 0.07524629131817263,
           0.06814200735815706, 0.04871316688887475, 0.07089593677164337,
           0.03533672325093177, 0.06868189815852659]
    w2t = [0.00469557296482457, 0.016544022768030475, 0.009747992549313118,
           0.011300210088528152, 0.024037709258814054, 0.01950778445716192,
           0.01443250464759355, 0.06053793055327338, 0.023197803106458133,
           0.02790630236675757, 0.06527159590975776, 0.048541680052673536,
           0.050393003790489777, 0.0654152798705545, 0.09578821783472778,
           0.09373414553186947, 0.07711477243101583, 0.11139356565242008,
           0.05986436233300792, 0.12057554383272853]
    @test isapprox(w1.weights, w1t, rtol = 5.0e-6)
    @test isapprox(w2.weights, w2t, rtol = 1.0e-5)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.0005)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.001)
end

@testset "SSkew" begin
    portfolio = OmniPortfolio(; prices = prices,
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = SSkew()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.04762767201257773, 0.05277763009753849, 0.04313912780375195,
           0.04073166143555511, 0.04654544740226561, 0.05132432402431435,
           0.028822263937020677, 0.07957772403554368, 0.03761397860273206,
           0.04380842958871217, 0.08400524915661846, 0.03702649726168862,
           0.03335525728577381, 0.06020169359842145, 0.040429991668753405,
           0.05043723225818501, 0.04929982465460814, 0.07086786182159446,
           0.043802565657043886, 0.058605567697301054]
    w2t = [0.004763599427643488, 0.010492170146556576, 0.012900259783122791,
           0.016254662775559696, 0.023312371632547447, 0.02919488184598214,
           0.020187912383493548, 0.05923845240591326, 0.03132528772972758,
           0.040805941704882144, 0.08738039411791934, 0.04016178659587393,
           0.03861542497085767, 0.07706578085675182, 0.052116271810969686,
           0.07136137384266647, 0.08035387404428683, 0.1175667208351577,
           0.07696549825130941, 0.10993733483877846]
    @test isapprox(w1.weights, w1t, rtol = 0.0001)
    @test isapprox(w2.weights, w2t, rtol = 1.0e-4)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.0005)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.0005)
end

@testset "DVaR" begin
    portfolio = OmniPortfolio(; prices = prices[(end - 50):end],
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = BDVariance()

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.041282715159969716, 0.04983418210656033, 0.04356426842967805,
           0.04375201152529006, 0.052076995648842765, 0.05757219578037072,
           0.04262153320098835, 0.06069244060278705, 0.04383224021553362,
           0.04575148160420536, 0.07483608960225534, 0.03556830817557716,
           0.02745910033988576, 0.06312322997003714, 0.03475209520623468,
           0.052110338074831834, 0.04920424074835751, 0.060088297745948316,
           0.046346922629732314, 0.07553131323291397]
    w2t = [0.003976406116005965, 0.009405999250255676, 0.012692268233392381,
           0.01783744903447256, 0.02544441595576468, 0.032636904639478555,
           0.02964589511592989, 0.04326901946969708, 0.03704892159886207,
           0.04274803450384758, 0.0747050918423663, 0.038321410427095685,
           0.030758439549623255, 0.08150400702314292, 0.048278203179960955,
           0.07414816531958743, 0.07857960227001794, 0.09763304621423306,
           0.08249398239281651, 0.13887273786344953]
    @test isapprox(w1.weights, w1t, rtol = 5.0e-5)
    @test isapprox(w2.weights, w2t, rtol = 5.0e-5)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.0005)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.0005)
end

@testset "GMD" begin
    portfolio = OmniPortfolio(; prices = prices[(end - 200):end],
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.75))))
    asset_statistics!(portfolio)

    rm = GMD(; owa = OWASettings(; approx = false))

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.04803547750881911, 0.05110378808817606, 0.045744535143979456,
           0.0401591940551555, 0.04820271181945354, 0.049480772022897544,
           0.029817165753273638, 0.06382434140445212, 0.047278147548602704,
           0.04657225285433487, 0.06792646315264042, 0.026940518272695023,
           0.023139927344914143, 0.0730447700398832, 0.028269792959212576,
           0.04916435454256209, 0.056826111828608854, 0.07493459440699926,
           0.05401678163830339, 0.07551829961503662]
    w2t = [0.0052168653727435324, 0.010875041401541045, 0.015252697855293935,
           0.018481723701732653, 0.028493184679311317, 0.02747420746238557,
           0.023248044382348478, 0.04628343130752336, 0.03778803682979785,
           0.04317310948945797, 0.06425862358082006, 0.028232000044163038,
           0.025155426631292603, 0.09117101688071873, 0.03757808278184953,
           0.06309686337156944, 0.09825614373133428, 0.11627448958576403,
           0.09026796539690063, 0.12942304551345193]
    @test isapprox(w1.weights, w1t, rtol = 5.0e-5)
    @test isapprox(w2.weights, w2t, rtol = 0.0001)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.001)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.0005)

    rm = GMD(; owa = OWASettings(; approx = true))

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.04804176713883893, 0.05104724299739746, 0.04574875402236941,
           0.04012962719713228, 0.04815875955840716, 0.04933616200008279,
           0.029706105017130887, 0.06367477406014153, 0.04748519555775158,
           0.04665149434353952, 0.0675631982393003, 0.02704670146538231,
           0.023214330721524467, 0.07291756529139848, 0.028301862554273645,
           0.049102692654923646, 0.05684559150520732, 0.07510436307248146,
           0.05424976913183064, 0.07567404347088627]
    w2t = [0.005221701242699852, 0.01088142933833096, 0.015245989565332926,
           0.01844755738581367, 0.02832444832297849, 0.027741417167144008,
           0.023135277022809514, 0.0461316854171331, 0.03787994983663463,
           0.04323850965363985, 0.06418371868592332, 0.02851724622975968,
           0.025447120396264768, 0.0909237645940213, 0.03781632936438383,
           0.06292575605625167, 0.09814660172282262, 0.11653789569534632,
           0.09019739278381154, 0.12905620951889796]
    @test isapprox(w1.weights, w1t, rtol = 5.0e-5)
    @test isapprox(w2.weights, w2t, rtol = 5.0e-5)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.05)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.005)
end

@testset "TG" begin
    portfolio = OmniPortfolio(; prices = prices[(end - 125):end],
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.9))))
    asset_statistics!(portfolio)

    rm = TG(; owa = OWASettings(; approx = false))

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    portfolio.risk_budget /= sum(portfolio.risk_budget)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.038764768981499845, 0.07263706983700537, 0.04228339226242435,
           0.0435411990063813, 0.048774699348804414, 0.039676776202074104,
           0.03231569528296526, 0.05297550687912629, 0.03844632457767705,
           0.04978778365499336, 0.055347007035070256, 0.06518988423572826,
           0.034132382278224085, 0.05239068690649956, 0.04926897149717854,
           0.053690745556068495, 0.049275704404779644, 0.04936498510427762,
           0.04217840509303159, 0.08995801185619062]
    w2t = [0.0038201872636861034, 0.013371366978310375, 0.01154238813703943,
           0.017571807532298662, 0.019897636478913447, 0.022692934297274116,
           0.0214029490852748, 0.03786440897005283, 0.03148120903979511,
           0.048284735121110235, 0.057256192158012524, 0.07488747144376684,
           0.03855613540473131, 0.07497989888742033, 0.06385953604838171,
           0.0813630397309213, 0.07603774634340942, 0.07779457508307593,
           0.07642790345721767, 0.1509078785393079]
    @test isapprox(w1.weights, w1t, rtol = 5.0e-5)
    @test isapprox(w2.weights, w2t, rtol = 5.0e-5)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.05)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.05)

    rm = TG(; owa = OWASettings(; approx = true))

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.038740466095828284, 0.07002876653572743, 0.04194119773895824,
           0.04494827890397753, 0.04948102362024745, 0.039928092992390314,
           0.032657023732753664, 0.053336176036027395, 0.03819620335043525,
           0.04917066142522329, 0.05460927920861385, 0.06730801763590079,
           0.03272434270065661, 0.053073199358552196, 0.04968699383594111,
           0.05372969101047005, 0.049217774918763224, 0.04857885542254007,
           0.0424137253877012, 0.0902302300892922]
    w2t = [0.0037698728023252306, 0.013204506974378116, 0.011539552353705813,
           0.01732091437727659, 0.020227283064655915, 0.02242528734969352,
           0.02138248981408943, 0.03823152182275527, 0.031463918665103986,
           0.047817931612775345, 0.05671602710914603, 0.07436882289918073,
           0.0385819640616973, 0.07417489965002216, 0.06486320638120524, 0.0803528521152473,
           0.07534879190537207, 0.07800719011461071, 0.07566097593127415,
           0.15454199099548505]
    @test isapprox(w1.weights, w1t, rtol = 5.0e-5)
    @test isapprox(w2.weights, w2t, rtol = 5.0e-5)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.1)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.1)
end

@testset "TGRG" begin
    portfolio = OmniPortfolio(; prices = prices[(end - 200):end],
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false))))
    asset_statistics!(portfolio)

    rm = TGRG(;)

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.04253504052591617, 0.04991570998894274, 0.04298361867322103,
           0.034781792979486484, 0.04824909571411739, 0.053204991729475064,
           0.03659379499268876, 0.06323702251704609, 0.04112095440849473,
           0.04436007858442393, 0.08117585058855487, 0.04385098964509536, 0.025563115008997,
           0.06928261553950593, 0.036317498603680005, 0.048488866652573646,
           0.04932884872222516, 0.0627983762077992, 0.04589951058488181,
           0.08031222833287464]
    w2t = [0.004134421101898551, 0.009449899778879613, 0.013177971399256623,
           0.015383843365554328, 0.022528960922832207, 0.03056818096247944,
           0.026476370967053044, 0.054329900489308594, 0.03456852749670496,
           0.04087959537828222, 0.07959616159750021, 0.0472103000499494,
           0.030673162574130136, 0.08496604265850279, 0.05293487923242808,
           0.06603208610124492, 0.07860589834427198, 0.10022583042887317,
           0.07990952964634396, 0.1283484375045057]
    @test isapprox(w1.weights, w1t, rtol = 1.0e-5)
    @test isapprox(w2.weights, w2t, rtol = 5.0e-5)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.05)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.1)
end

@testset "OWA" begin
    portfolio = OmniPortfolio(; prices = prices[(end - 200):end],
                              solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                                               :check_sol => (allow_local = true,
                                                                              allow_almost = true),
                                                               :params => Dict("verbose" => false,
                                                                               "max_step_fraction" => 0.9))))
    asset_statistics!(portfolio)

    rm = OWA(; owa = OWASettings(; approx = false))

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.04803547750881911, 0.05110378808817606, 0.045744535143979456,
           0.0401591940551555, 0.04820271181945354, 0.049480772022897544,
           0.029817165753273638, 0.06382434140445212, 0.047278147548602704,
           0.04657225285433487, 0.06792646315264042, 0.026940518272695023,
           0.023139927344914143, 0.0730447700398832, 0.028269792959212576,
           0.04916435454256209, 0.056826111828608854, 0.07493459440699926,
           0.05401678163830339, 0.07551829961503662]
    w2t = [0.0052168653727435324, 0.010875041401541045, 0.015252697855293935,
           0.018481723701732653, 0.028493184679311317, 0.02747420746238557,
           0.023248044382348478, 0.04628343130752336, 0.03778803682979785,
           0.04317310948945797, 0.06425862358082006, 0.028232000044163038,
           0.025155426631292603, 0.09117101688071873, 0.03757808278184953,
           0.06309686337156944, 0.09825614373133428, 0.11627448958576403,
           0.09026796539690063, 0.12942304551345193]
    @test isapprox(w1.weights, w1t, rtol = 5.0e-5)
    @test isapprox(w2.weights, w2t, rtol = 0.0001)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.001)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.0005)

    rm = OWA(; owa = OWASettings(; approx = true))

    portfolio.risk_budget = []
    w1 = optimise!(portfolio; type = RP(), rm = rm)
    rc1 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc1, hrc1 = extrema(rc1)

    portfolio.risk_budget = 1:size(portfolio.returns, 2)
    w2 = optimise!(portfolio; type = RP(), rm = rm)
    rc2 = risk_contribution(portfolio; type = :RP, rm = rm)
    lrc2, hrc2 = extrema(rc2)

    w1t = [0.04804176713883893, 0.05104724299739746, 0.04574875402236941,
           0.04012962719713228, 0.04815875955840716, 0.04933616200008279,
           0.029706105017130887, 0.06367477406014153, 0.04748519555775158,
           0.04665149434353952, 0.0675631982393003, 0.02704670146538231,
           0.023214330721524467, 0.07291756529139848, 0.028301862554273645,
           0.049102692654923646, 0.05684559150520732, 0.07510436307248146,
           0.05424976913183064, 0.07567404347088627]
    w2t = [0.005221701242699852, 0.01088142933833096, 0.015245989565332926,
           0.01844755738581367, 0.02832444832297849, 0.027741417167144008,
           0.023135277022809514, 0.0461316854171331, 0.03787994983663463,
           0.04323850965363985, 0.06418371868592332, 0.02851724622975968,
           0.025447120396264768, 0.0909237645940213, 0.03781632936438383,
           0.06292575605625167, 0.09814660172282262, 0.11653789569534632,
           0.09019739278381154, 0.12905620951889796]
    @test isapprox(w1.weights, w1t, rtol = 5.0e-5)
    @test isapprox(w2.weights, w2t, rtol = 5.0e-5)
    @test isapprox(hrc1 / lrc1, 1, rtol = 0.05)
    @test isapprox(hrc2 / lrc2, 20, rtol = 0.005)
end
