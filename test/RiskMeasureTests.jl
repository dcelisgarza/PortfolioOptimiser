using Test,
    PortfolioOptimiser,
    DataFrames,
    TimeSeries,
    CSV,
    Dates,
    ECOS,
    SCS,
    Clarabel,
    COSMO,
    OrderedCollections,
    LinearAlgebra,
    StatsBase,
    Logging

import PortfolioOptimiser.HRRiskMeasures

Logging.disable_logging(Logging.Warn)

A = TimeArray(CSV.File("./assets/stock_prices.csv"), timestamp = :date)
Y = percentchange(A)
returns = dropmissing!(DataFrame(Y))

@testset "Risk measures" begin
    portfolio = Portfolio(
        returns = returns,
        solvers = OrderedDict(
            :Clarabel => Dict(
                :solver => (Clarabel.Optimizer),
                :params => Dict("verbose" => false),
            ),
            :COSMO =>
                Dict(:solver => COSMO.Optimizer, :params => Dict("verbose" => false)),
            :ECOS =>
                Dict(:solver => ECOS.Optimizer, :params => Dict("verbose" => false)),
            :SCS => Dict(:solver => SCS.Optimizer, :params => Dict("verbose" => 0)),
        ),
    )
    asset_statistics!(portfolio)

    N = length(portfolio.assets)
    w = fill(1 / N, N)

    @test abs(
        calc_risk(w, portfolio.returns; sigma = portfolio.cov, rm = :Variance) -
        0.000101665490230637,
    ) < eps()
    @test abs(
        calc_risk(w, portfolio.returns; sigma = portfolio.cov, rm = :SD) -
        0.010082930637004155,
    ) < eps()
    @test abs(
        calc_risk(w, portfolio.returns; sigma = portfolio.cov, rm = :MAD) -
        0.007418863748729646,
    ) < eps()
    @test abs(
        calc_risk(w, portfolio.returns; sigma = portfolio.cov, rm = :SSD) -
        0.007345533015355076,
    ) < eps()
    @test abs(
        calc_risk(w, portfolio.returns; sigma = portfolio.cov, rm = :FLPM) -
        0.0034827678064358134,
    ) < eps()
    @test abs(
        calc_risk(w, portfolio.returns; sigma = portfolio.cov, rm = :SLPM) -
        0.007114744825145661,
    ) < eps()
    @test abs(
        calc_risk(w, portfolio.returns; sigma = portfolio.cov, rm = :WR) -
        0.043602428699089285,
    ) < eps()
    @test abs(
        calc_risk(w, portfolio.returns; sigma = portfolio.cov, rm = :VaR) -
        0.016748899891587572,
    ) < eps()
    @test abs(
        calc_risk(w, portfolio.returns; sigma = portfolio.cov, rm = :CVaR) -
        0.02405795664064266,
    ) < eps()
    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :EVaR,
            solvers = portfolio.solvers,
        ) - 0.030225422932337445,
    ) < 9e-8
    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :RVaR,
            solvers = portfolio.solvers,
        ) - 0.03586321171352101,
    ) < 1e-5
    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :MDD,
            solvers = portfolio.solvers,
        ) - 0.1650381304766847,
    ) < 2.1 * eps()
    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :ADD,
            solvers = portfolio.solvers,
        ) - 0.02762516797999026,
    ) < eps()
    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :DaR,
            solvers = portfolio.solvers,
        ) - 0.09442013028621254,
    ) < 4.6 * eps()
    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :CDaR,
            solvers = portfolio.solvers,
        ) - 0.11801077171629008,
    ) < 2 * eps()
    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :UCI,
            solvers = portfolio.solvers,
        ) - 0.0402491262027023,
    ) < eps()
    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :EDaR,
            solvers = portfolio.solvers,
        ) - 0.13221264782750258,
    ) < 4e-8

    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :RDaR,
            solvers = portfolio.solvers,
        ) - 0.14476333638845212,
    ) < 4.6e-6

    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :MDD_r,
            solvers = portfolio.solvers,
        ) - 0.15747952419681518,
    ) < eps()
    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :ADD_r,
            solvers = portfolio.solvers,
        ) - 0.0283271101845512,
    ) < eps()
    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :DaR_r,
            solvers = portfolio.solvers,
        ) - 0.09518744803693206,
    ) < eps()
    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :CDaR_r,
            solvers = portfolio.solvers,
        ) - 0.11577944159793968,
    ) < eps()
    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :UCI_r,
            solvers = portfolio.solvers,
        ) - 0.040563874281498415,
    ) < eps()
    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :EDaR_r,
            solvers = portfolio.solvers,
        ) - 0.12775945574727807,
    ) < 7.7e-8
    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :RDaR_r,
            solvers = portfolio.solvers,
        ) - 0.13863825698673474,
    ) < 8.3e-6
    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :Kurt,
            solvers = portfolio.solvers,
        ) - 0.0002220921162540514,
    ) < eps()
    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :SKurt,
            solvers = portfolio.solvers,
        ) - 0.00017326399202890477,
    ) < eps()
    @test abs(
        calc_risk(w, portfolio.returns; sigma = portfolio.cov, rm = :GMD) -
        0.010916540360808049,
    ) < eps()
    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :RG,
            solvers = portfolio.solvers,
        ) - 0.08841083118500939,
    ) < eps()
    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :RCVaR,
            solvers = portfolio.solvers,
        ) - 0.046068669089612116,
    ) < eps()
    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :TG,
            solvers = portfolio.solvers,
        ) - 0.027380708685309275,
    ) < eps()
    @test abs(
        calc_risk(
            w,
            portfolio.returns;
            sigma = portfolio.cov,
            rm = :RTG,
            solvers = portfolio.solvers,
        ) - 0.051977750343340984,
    ) < eps()

    portfolio = Portfolio(
        returns = returns,
        solvers = OrderedDict(
            :ECOS => Dict(
                :solver => ECOS.Optimizer,
                :params => Dict("verbose" => false, "maxit" => 200),
            ),
        ),
    )
    asset_statistics!(portfolio, calc_kurt = false)
    opt_port!(portfolio)
    T = size(returns, 1)
    owa_w = fill(1 / T, T)

    @test isapprox(
        dot(sort(portfolio.returns * portfolio.optimal[:Trad].weights), owa_gmd(T) / 2),
        calc_risk(portfolio, rm = :OWA),
    )
    @test isapprox(
        dot(sort(portfolio.returns * portfolio.optimal[:Trad].weights), owa_w),
        calc_risk(portfolio, rm = :OWA, owa_w = owa_w),
    )
    @test isapprox(
        dot(sort(portfolio.returns * portfolio.optimal[:Trad].weights), fill(1 / T, T)),
        calc_risk(portfolio, rm = :OWA, owa_w = 1),
    )

    portfolio = Portfolio(
        returns = returns,
        solvers = OrderedDict(
            :Clarabel => Dict(
                :solver => Clarabel.Optimizer,
                :params => Dict("verbose" => false, "max_step_fraction" => 0.75),
            ),
        ),
    )
    asset_statistics!(portfolio, calc_kurt = false)
    opt_port!(portfolio, rm = :EVaR)
    evar_r1 = calc_risk(portfolio, rm = :EVaR)
    evar_r2 = ERM(
        portfolio.returns * portfolio.optimal[:Trad].weights,
        portfolio.z[:z_evar],
        portfolio.alpha,
    )
    @test isapprox(evar_r1, evar_r2, rtol = 2e-6)

    opt_port!(portfolio, rm = :EVaR, obj = :Min_Risk)
    evar_r1 = calc_risk(portfolio, rm = :EVaR)
    evar_r2 = ERM(
        portfolio.returns * portfolio.optimal[:Trad].weights,
        portfolio.z[:z_evar],
        portfolio.alpha,
    )
    @test isapprox(evar_r1, evar_r2, rtol = 3e-6)
end

@testset "Risk contribution" begin
    portfolio = HCPortfolio(
        returns = returns,
        solvers = Dict(
            :Clarabel => Dict(
                :solver => (Clarabel.Optimizer),
                :params => Dict("verbose" => false, "max_step_fraction" => 0.75),
            ),
        ),
    )
    asset_statistics!(portfolio)
    type = :NCO

    w = opt_port!(portfolio, type = type, linkage = :complete)

    sr = sharpe_ratio(portfolio; rf = 0.0001, type = type)
    srt =
        (dot(portfolio.mu, portfolio.optimal[type].weights) - 0.0001) /
        calc_risk(portfolio, type = type)
    @test isapprox(sr, srt)

    rc1 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[1],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc1t = [
        0.0002043317769246514,
        0.0002995623491405207,
        6.169287552636295e-5,
        9.634865044295322e-5,
        5.082896801112619e-9,
        0.00034337120153934904,
        3.2763706405616187e-9,
        0.0009619350220394237,
        8.758491339785367e-9,
        0.0002206877870265238,
        0.0019490071629611817,
        2.218547923802908e-5,
        7.664771633959982e-6,
        0.0007513270935999037,
        4.844813540042939e-9,
        0.0002623961236317563,
        0.000656402405607018,
        0.0014321570107310025,
        1.244253167821144e-8,
        0.0005171135155959228,
    ]
    @test isapprox(rc1, rc1t)
    rc2 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[2],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc2t = [
        0.0001380815699298986,
        0.00019925151614937664,
        4.062965648210803e-5,
        7.418620660364683e-5,
        3.4891096386592252e-9,
        0.00023655766731905473,
        2.1867442780123953e-9,
        0.0006895517471811284,
        6.1065063183530015e-9,
        0.00015967497696297046,
        0.0015393674261487092,
        1.7927199664702238e-5,
        6.013163592600286e-6,
        0.000542111784582887,
        3.341383232944497e-9,
        0.00020561440035586355,
        0.0004407002852317237,
        0.001038982476098022,
        8.47898776659832e-9,
        0.0003570944566843724,
    ]
    @test isapprox(rc2, rc2t)
    rc3 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[3],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc3t = [
        0.00015957676999110303,
        0.0002161683447138032,
        4.936423384938421e-5,
        8.114836674724877e-5,
        3.975528900167013e-9,
        0.00025525602449998395,
        2.672282004516617e-9,
        0.0007120955667980071,
        6.457087734146971e-9,
        0.00017345837638179688,
        0.0013862794863973452,
        1.4881009641919718e-5,
        5.355142677528552e-6,
        0.0005416732009864074,
        2.8392783684180056e-9,
        0.00018816181077682093,
        0.0004788111731695251,
        0.001000436867710701,
        9.109740458446344e-9,
        0.00037976103402036936,
    ]
    @test isapprox(rc3, rc3t)
    rc4 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[4],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc4t = [
        6.150374831505536e-5,
        8.852938976873058e-5,
        1.7872070908633695e-5,
        3.213305285700051e-5,
        1.1588896348050826e-9,
        0.00012920908005438104,
        7.189438616512586e-10,
        0.00032807443426581003,
        2.590791953814428e-9,
        7.418593303307601e-5,
        0.0007380995632942357,
        8.907955677435096e-6,
        3.381641600345915e-6,
        0.0002669549745679846,
        1.8410676220525518e-9,
        8.439068980034995e-5,
        0.00018322423442083282,
        0.0004801745721015088,
        3.578061826292522e-9,
        0.00015870791712950183,
    ]
    @test isapprox(rc4, rc4t)
    rc5 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[5],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc5t = [
        0.00015147451873503555,
        0.00020259581450168387,
        4.592391406855149e-5,
        7.582044551069637e-5,
        3.4100023085507438e-9,
        0.000267954161931266,
        2.4060087544421667e-9,
        0.0006931873707458243,
        6.097599421809764e-9,
        0.00016833569433615745,
        0.0013472086593758164,
        1.5279352828287952e-5,
        5.815181314079728e-6,
        0.0005437001314957578,
        3.1842537923752013e-9,
        0.00017077954483574995,
        0.0004429203609246914,
        0.0009642664911010222,
        8.553922940553951e-9,
        0.000358452346498508,
    ]
    @test isapprox(rc5, rc5t)
    rc6 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[6],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc6t = [
        0.0012753689781182865,
        0.0009230486412801511,
        0.00036707730161709127,
        0.000456405957056586,
        1.855432991285211e-8,
        0.0020205216509987865,
        2.238496288874805e-8,
        0.005359710293353387,
        4.8932935259731246e-8,
        0.0009182785326375532,
        0.009845735266354792,
        0.00011893063912270837,
        4.045342859878976e-5,
        0.0056156452313906756,
        1.9660273240434573e-8,
        0.0013532069674677988,
        0.0026457088669791084,
        0.009735515063029943,
        6.594455358562102e-8,
        0.0013454702859920006,
    ]
    @test isapprox(rc6, rc6t)
    rc7 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[7],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc7t = [
        0.0005522991721143591,
        0.0007271797314489727,
        0.00017686115106614188,
        0.00026119263338327664,
        1.3751595645244384e-8,
        0.000907935334675444,
        1.036396257211078e-8,
        0.0021732869999688386,
        2.2950340861485668e-8,
        0.0006106926026018825,
        0.004557383718040645,
        4.809246324881231e-5,
        1.972869441870109e-5,
        0.0017939536237165286,
        1.237062962420478e-8,
        0.0005408134875952555,
        0.0015968961868263567,
        0.0027927335667786,
        3.234802753779881e-8,
        0.001246441373903173,
    ]
    @test isapprox(rc7, rc7t)
    rc8 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[8],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc8t = [
        0.0008022818895344849,
        0.0007851696746127276,
        0.0002458243760413473,
        0.00031750192352739706,
        1.7997588479331985e-8,
        0.0012599879345918457,
        1.0375523545022552e-8,
        0.0033320148122700085,
        3.200930441696228e-8,
        0.0007720026911112777,
        0.006240687667867018,
        7.347746664103954e-5,
        2.4650099030824156e-5,
        0.003146996130187633,
        1.5798261464694915e-8,
        0.0008201378018035108,
        0.001947171859827255,
        0.005621191954222265,
        4.480951725817828e-8,
        0.0014152486753566998,
    ]
    @test isapprox(rc8, rc8t, rtol = 5e-3)
    rc9 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[9],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc9t = [
        0.001467735146033845,
        0.0016992878484720726,
        0.00040364152527904497,
        0.0007573562161191523,
        -2.064805193961807e-9,
        0.001110166630802317,
        1.5671646997071205e-8,
        0.004270716208611099,
        4.84215019826098e-8,
        -0.00018781770760409005,
        0.004291798388046436,
        9.488262238350787e-5,
        3.121645853555125e-5,
        0.0049213752073145505,
        1.822245380707308e-8,
        0.0010483869787605313,
        0.0008392634387711473,
        0.00022560194148464,
        -1.5598529963457856e-8,
        -0.0021680083728532395,
    ]
    @test isapprox(rc9, rc9t, atol = 0.02)
    rc10 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[10],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc10t = [
        0.003169800499230103,
        0.00850096773161657,
        0.0012354850753716405,
        0.0022760846457229814,
        2.453232361490061e-8,
        0.006555904275636807,
        1.577275866024571e-8,
        0.017536246823819195,
        1.549684237790431e-7,
        0.002740935022840686,
        0.02381840658462156,
        3.0097672038197545e-5,
        -5.450150912727055e-5,
        0.015728955073009823,
        1.0232654277949033e-7,
        -0.000381009902315803,
        0.008399119897043065,
        0.01960007240698465,
        1.9515266247782393e-7,
        0.006149850910171047,
    ]
    @test isapprox(rc10, rc10t, rtol = 4e-8)
    rc11 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[11],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc11t = [
        0.00017098306237774526,
        0.00031485521274335777,
        -3.456116165398102e-5,
        4.7878301040508756e-5,
        -1.1423284706076312e-8,
        0.0011780043567137068,
        -4.215725208371653e-9,
        0.002348668494269881,
        -4.410041166207647e-10,
        0.00042627446582750404,
        0.00610827061646062,
        6.705275021163016e-5,
        3.265004220561284e-5,
        0.0031561922713772297,
        2.6953465370028777e-8,
        -4.381670585821136e-5,
        -3.777408249541422e-5,
        0.004699519751246184,
        1.3462752938198555e-9,
        0.0010198994709112474,
    ]
    @test isapprox(rc11, rc11t, rtol = 3e-8)
    rc12 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[12],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc12t = [
        0.002165670927711741,
        0.0021372836702877812,
        0.0007881948925921736,
        0.001786788942625951,
        -2.713165359147408e-8,
        0.00544793691766228,
        2.6689777571387162e-8,
        0.017979931704548688,
        5.927474924374622e-8,
        0.002187854822725766,
        0.01673088463069062,
        -0.00011589915207514704,
        -3.002635340110656e-5,
        0.013131405008798449,
        6.432259354913779e-8,
        0.0002035897189057851,
        0.0006655802479420341,
        0.017330874943114465,
        8.069519262107062e-8,
        0.0012602504594063512,
    ]
    @test isapprox(rc12, rc12t, rtol = 4e-8)
    rc13 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[13],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc13t = [
        0.00044578234709448784,
        0.0005408421638500287,
        9.100938621954006e-5,
        0.0003329782943937869,
        -1.217367514752897e-8,
        0.0017762869071605227,
        1.3633483399469615e-9,
        0.004368066531135226,
        6.708602680159116e-9,
        0.0007217301593340703,
        0.007427157655732962,
        4.8056603865446717e-5,
        2.3742892039390573e-5,
        0.004748659818943777,
        3.076167359492783e-8,
        -7.896489650277223e-5,
        0.0001533630807554869,
        0.007196410254846729,
        1.2729798642087043e-8,
        0.0010696958252997824,
    ]
    @test isapprox(rc13, rc13t, rtol = 3e-8)
    rc14 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[14],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc14t = [
        0.0025874386342171216,
        0.002944542220718042,
        0.000987971753299987,
        0.0017302128214052351,
        -1.565949697920388e-8,
        0.0060430623123880756,
        3.309479456716943e-8,
        0.019036699870907652,
        7.758852201078288e-8,
        0.0028602291392565466,
        0.018524828686190882,
        -0.00010019515911698917,
        -1.4387136677303111e-5,
        0.014326487861484773,
        6.157817577777723e-8,
        0.0011990819231526729,
        0.001761420870296303,
        0.017516825276248232,
        1.0252013112435822e-7,
        0.0023737435155140726,
    ]
    @test isapprox(rc14, rc14t, rtol = 5e-1)
    rc15 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[15],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc15t = [
        0.0021281344291990225,
        0.0048206780654304225,
        0.0011202444845235847,
        0.0020239379327019443,
        -8.684164584476346e-10,
        0.00710234565985776,
        2.6864379865473526e-8,
        0.015997198518344503,
        9.98306559435132e-8,
        0.003339886484040803,
        0.017157908749250633,
        -7.316730771466198e-5,
        -5.426298361035107e-6,
        0.017653450735322842,
        5.219094415124055e-8,
        0.0015515563255866951,
        0.003154378486365758,
        0.019172911193224642,
        1.5104936261894233e-7,
        0.006609830825115192,
    ]
    @test isapprox(rc15, rc15t, rtol = 3e-1)
    rc16 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[16],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc16t = [
        4.5537388375515034e-6,
        5.728035359594009e-6,
        1.3188431785532899e-6,
        1.5402672215197086e-6,
        1.1004955883161303e-10,
        6.702646005953224e-6,
        5.609344126093619e-11,
        1.8108151673411454e-5,
        1.7589283802735315e-10,
        4.164764912080477e-6,
        3.426603731786716e-5,
        3.935135046887245e-7,
        1.358345606111785e-7,
        1.588496554427827e-5,
        9.254478189395859e-11,
        4.829105883918644e-6,
        1.2789338357227128e-5,
        2.8024620435964843e-5,
        2.499520820201564e-10,
        9.870480166259921e-6,
    ]
    @test isapprox(rc16, rc16t)
    rc17 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[17],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc17t = [
        3.6240571030528143e-6,
        4.17915863499695e-6,
        1.1249822804573928e-6,
        1.551377706985783e-6,
        9.040225593229637e-11,
        5.498620348197071e-6,
        4.886733034688475e-11,
        1.4468345472588048e-5,
        1.448661092321173e-10,
        3.6813444728779443e-6,
        2.771003266300391e-5,
        3.019865841624398e-7,
        1.0664667709907327e-7,
        1.2634142900265873e-5,
        6.594072923864508e-11,
        3.732057056498235e-6,
        9.72210280378955e-6,
        2.2662927998943675e-5,
        2.0360848074165503e-10,
        7.290870867671044e-6,
    ]
    @test isapprox(rc17, rc17t)
    rc18 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[18],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc18t = [
        0.0002096824054165285,
        0.00031503793115469957,
        6.336095437543127e-5,
        0.00010685986876993121,
        5.274861642030768e-9,
        0.0003626163690194504,
        3.438495340818887e-9,
        0.0010351983093637742,
        9.11519383201117e-9,
        0.0002353309461006095,
        0.0021554582888681706,
        2.4617474164507444e-5,
        8.428266891592514e-6,
        0.0007823871115187119,
        4.941608019888408e-9,
        0.00029348811617173397,
        0.00067940764699,
        0.00154079646324721,
        1.2893321779069027e-8,
        0.0005491981950527325,
    ]
    @test isapprox(rc18, rc18t)
    rc19 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[19],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc19t = [
        0.0032973827609630783,
        0.003042024959807687,
        0.000757990270892174,
        0.0004729564250558196,
        6.75409670558095e-8,
        0.0033971354299340488,
        3.3831818914275064e-8,
        0.00885694162207531,
        9.743045251014718e-8,
        0.0016934068117549893,
        0.017130745833034436,
        0.00021450838486379573,
        6.40428968738009e-5,
        0.011059227824595178,
        3.734989485464956e-8,
        0.003442998400899376,
        0.006909886819618069,
        0.016125263499292927,
        1.3480810199689591e-7,
        0.005248448193225625,
    ]
    @test isapprox(rc19, rc19t)
    rc20 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[20],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc20t = [
        0.0009429446479677084,
        0.0014354623507010409,
        0.00030574960255158145,
        0.00043395287499072314,
        2.3949054610380434e-8,
        0.0015696368747361144,
        1.635549028094545e-8,
        0.004087439419559402,
        4.131677604003282e-8,
        0.0010545571613277793,
        0.009005084095339663,
        9.847904330022261e-5,
        3.417495728495988e-5,
        0.0034231866903754703,
        2.7648209961273016e-8,
        0.0010129481810459949,
        0.003090211199158524,
        0.0061372909886968025,
        6.097408083308898e-8,
        0.0023731524088898585,
    ]
    @test isapprox(rc20, rc20t)
    rc21 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[21],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc21t = [
        0.0006457897472164223,
        0.0008082741012697203,
        0.00019718334299559555,
        0.00029583928788002114,
        1.575079641605457e-8,
        0.0010532795350143144,
        9.957183342810415e-9,
        0.0027381977121483073,
        2.6714697962659635e-8,
        0.0006790842212939265,
        0.005028864682646723,
        5.202899040005516e-5,
        2.195756660907234e-5,
        0.002145472436187084,
        1.4673866707855005e-8,
        0.0006227376116128751,
        0.0018485994356489486,
        0.003529971575033981,
        3.6970648290685165e-8,
        0.0014109089518889101,
    ]
    @test isapprox(rc21, rc21t)
    rc22 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[22],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc22t = [
        0.0011285994851699052,
        0.001651617931059805,
        0.0003434748623697903,
        0.0004771830384258517,
        2.64181468232469e-8,
        0.0018809958158949834,
        1.613483858692946e-8,
        0.00524479201871571,
        4.84635073617107e-8,
        0.0011393685572644212,
        0.009560694543565208,
        0.00010860709483951946,
        4.0960114806534485e-5,
        0.0040047380329476445,
        3.114267696344471e-8,
        0.001101812408402584,
        0.0036124329896885478,
        0.007168453839289718,
        6.967147882434593e-8,
        0.002784459960306457,
    ]
    @test isapprox(rc22, rc22t)
    rc23 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[23],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc23t = [
        0.00010484120270826424,
        0.00015751896557734978,
        3.168047722129822e-5,
        5.3429934275599464e-5,
        2.637430821015384e-9,
        0.0001813081846974613,
        1.7192476704094434e-9,
        0.0005175991546818871,
        4.557596911993637e-9,
        0.00011766547305030474,
        0.0010777291433052283,
        1.2308737082253722e-5,
        4.214133445796257e-6,
        0.00039119355575935593,
        2.470804007376836e-9,
        0.00014674405808586698,
        0.00033970382316666527,
        0.000770398231623605,
        6.446660889534513e-9,
        0.00027459909722505184,
    ]
    @test isapprox(rc23, rc23t)
    rc24 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[24],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc24t = [
        3.1819433681707446e-6,
        4.664915285426025e-6,
        9.607083099560354e-7,
        1.500383123035721e-6,
        7.915308139243035e-11,
        5.34712579977439e-6,
        5.102106968153829e-11,
        1.497967085378358e-5,
        1.3639103937807207e-10,
        3.436646275092983e-6,
        3.035078786511804e-5,
        3.45481939153146e-7,
        1.1935916007130024e-7,
        1.1699992529162337e-5,
        7.544554516426099e-11,
        4.086146649335944e-6,
        1.0221783977962497e-5,
        2.2302172317079938e-5,
        1.9376051898424832e-10,
        8.05271674029468e-6,
    ]
    @test isapprox(rc24, rc24t)
    rc25 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[25],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc25t = [
        0.02527777949747826,
        0.036944993893295024,
        0.0077436183621412856,
        0.012609057737328434,
        6.641250492232613e-7,
        0.043288997105333044,
        3.166963498381412e-7,
        0.12755841316955976,
        9.250921077902997e-7,
        0.025787315455259422,
        0.2602966815700747,
        0.002223840032258799,
        0.0007312735172864796,
        0.09868835008161234,
        5.919947570946168e-7,
        0.02993866032846658,
        0.07570883524121547,
        0.1837199304253683,
        1.3752096039080659e-6,
        0.06947838049421001,
    ]
    @test isapprox(rc25, rc25t)
    rc26 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[26],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc26t = [
        0.0003413407583671608,
        0.0010000767444783834,
        0.00015892570016932592,
        0.00013731680686144808,
        6.446670974039324e-9,
        0.00038258458575111595,
        1.3608046281420903e-8,
        0.0002811466106028946,
        2.88757420487164e-8,
        0.00033264672386085046,
        0.0032890725975529135,
        1.0945277620660658e-5,
        -3.7771634958897156e-6,
        0.0008607915632775599,
        -4.474178351151398e-9,
        0.000763527846731852,
        0.00231707638599503,
        0.001932151864278548,
        3.9007228701534015e-8,
        0.0010505738905969332,
    ]
    @test isapprox(rc26, rc26t)
    rc27 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[27],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc27t = [
        0.0017668411883556613,
        0.006240008426045844,
        0.00048207518731582344,
        0.004073702476931867,
        -5.365885606631388e-8,
        0.0024995435793289645,
        -4.591325682616042e-9,
        0.014878643001336091,
        1.294149398223138e-7,
        -0.0007120094769149866,
        0.017422049742951196,
        -0.00027330160020838906,
        -8.697440520377735e-5,
        0.007891017563355626,
        1.325471086507603e-7,
        -0.004349427653608286,
        0.004683437006847442,
        0.015858178769668684,
        1.5408259344716658e-7,
        -0.002389345519586607,
    ]
    @test isapprox(rc27, rc27t, rtol = 8e-8)
    rc28 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[28],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc28t = [
        0.0014956813422416504,
        0.004765694142138272,
        0.00029712626258168864,
        0.0036392245578399686,
        -6.006727318329411e-8,
        0.002833322809470405,
        5.758115150741776e-9,
        0.015785621885836643,
        1.215212275276242e-7,
        0.0003426850934151664,
        0.020328055395282697,
        -0.00027729616335175986,
        -0.00010615709643362813,
        0.010572694688215414,
        7.981885528925336e-8,
        -0.0035487008211951554,
        0.004031882372975964,
        0.012409606331562737,
        1.7404398142142277e-7,
        -0.001855372076895879,
    ]
    @test isapprox(rc28, rc28t, rtol = 6e-8)
    rc29 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[29],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc29t = [
        0.0029101442842961725,
        0.007711718426470436,
        0.0011333023863447454,
        0.002063104499564154,
        2.43243443356807e-8,
        0.005964545648035511,
        1.4759322323885605e-8,
        0.015987663208592413,
        1.4186789253933488e-7,
        0.0025455160900723895,
        0.021793373075010326,
        3.646329182637843e-5,
        -4.7782329450430896e-5,
        0.01440959983350298,
        9.25351912029027e-8,
        -0.00026834183690203396,
        0.00772929933996463,
        0.01808310073782593,
        1.7883826845430217e-7,
        0.005732059472059088,
    ]
    @test isapprox(rc29, rc29t, rtol = 5e-8)
    rc30 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[30],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc30t = [
        4.4444650198879414e-5,
        0.0006489439759989124,
        -6.038917121944762e-5,
        5.4974562557486935e-5,
        -2.3389620804567335e-8,
        0.0009000114985788902,
        -1.0565796206323896e-8,
        0.0047126923673419694,
        6.072081164998704e-9,
        3.947689019285961e-5,
        0.006960113401319051,
        5.575133378925191e-5,
        2.6790849528371517e-5,
        0.0025640675420084656,
        4.252684656270161e-8,
        -0.00023435128506429383,
        -2.9831041430169025e-5,
        0.004740440901350084,
        9.474904001065433e-9,
        0.0003810355799579022,
    ]
    @test isapprox(rc30, rc30t, rtol = 7e-8)
    rc31 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[31],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc31t = [
        0.0021182500050580854,
        0.002333517207493175,
        0.0007463818845233183,
        0.0017997294840590972,
        -2.5771794915395638e-8,
        0.005120253301426645,
        2.4044870586503734e-8,
        0.01773707478764297,
        6.536192972618225e-8,
        0.0020004966938158733,
        0.017365399404491996,
        -9.894450638429271e-5,
        -2.746083608198914e-5,
        0.012410127377783645,
        6.777210431493218e-8,
        9.310820843356123e-6,
        0.0012478013447449,
        0.017267096107201056,
        8.963341281664909e-8,
        0.0011765556912858963,
    ]
    @test isapprox(rc31, rc31t, rtol = 6e-8)
    rc32 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[32],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc32t = [
        0.00029598682251354234,
        0.000880482027924744,
        6.405515516733526e-5,
        0.0003260567212286317,
        -2.4062146020874645e-8,
        0.0014239749528273788,
        -5.7923963459062174e-9,
        0.006651677710715117,
        1.3474599173840509e-8,
        0.00033742734150077114,
        0.008108580154880638,
        3.8916427064549704e-5,
        1.872155139356002e-5,
        0.004122583778633337,
        4.451789916261966e-8,
        -0.0002539579300341345,
        0.00020639064416163433,
        0.007279110392728194,
        2.123730265922571e-8,
        0.00047556206480531656,
    ]
    @test isapprox(rc32, rc32t, rtol = 6e-8)
    rc33 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[33],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc33t = [
        0.0025005376391058847,
        0.0028047845222335297,
        0.0009476646391378851,
        0.0016639249141263807,
        -1.6297682046706538e-8,
        0.00571125322391676,
        3.1901218224297936e-8,
        0.01891843052699375,
        7.739278486985521e-8,
        0.002704631624356912,
        0.018038292369193715,
        -9.56332672919653e-5,
        -1.2222379100020259e-5,
        0.013503307559571673,
        6.069117235453273e-8,
        0.0012102258065326888,
        0.001848306756753214,
        0.016984221211004173,
        1.0226799102131595e-7,
        0.0020634837588942288,
    ]
    @test isapprox(rc33, rc33t, rtol = 9e-1)
    rc34 = risk_contribution(
        portfolio;
        rm = HRRiskMeasures[34],
        rf = 0.0,
        type = type,
        di = 1e-7,
    )
    rc34t = [
        0.0027100148725444553,
        0.004554277715286903,
        0.0010475331582390183,
        0.0018208193980917455,
        -8.747138386464612e-9,
        0.005024190550938391,
        2.151652814322071e-8,
        0.01827322149579135,
        8.696534473591966e-8,
        0.003543712628954843,
        0.022038955299867012,
        -0.00011865511285456548,
        -8.261380816177559e-6,
        0.014151056497800553,
        5.002064873083518e-8,
        0.0011313440927175648,
        0.003554741797799396,
        0.01405088450393791,
        1.326681504909494e-7,
        0.004374146926761834,
    ]
    @test isapprox(rc34, rc34t, rtol = 4e-1)
end
