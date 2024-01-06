using COSMO,
    CovarianceEstimation,
    CSV,
    Clarabel,
    HiGHS,
    LinearAlgebra,
    OrderedCollections,
    PortfolioOptimiser,
    Statistics,
    StatsBase,
    Test,
    TimeSeries,
    SCS

prices = TimeArray(CSV.File("./test/assets/stock_prices.csv"); timestamp = :date)

rf = 1.0329^(1 / 252) - 1
l = 2.0

PortfolioOptimiser.BoxMethods
PortfolioOptimiser.EllipseMethods

########################################

println("cov_lt1 = reshape(", vec(portfolio.cov_l), ", 20, 20)")
println("cov_ut1 = reshape(", vec(portfolio.cov_u), ", 20, 20)")
println("cov_mut1 = ", sparse(portfolio.cov_mu))
println("cov_sigmat1 = ", sparse(portfolio.cov_sigma))
println("d_mut1 = ", portfolio.d_mu)
println("k_mut1 = ", portfolio.k_mu)
println("k_sigmat1 = ", portfolio.k_sigma)

println("kurtt = reshape(", vec(kurt), ", 16, 16)")
println("skurtt = reshape(", vec(skurt), ", 16, 16)")

println("w1t = ", w1.weights, "\n")
println("w2t = ", w2.weights, "\n")
println("w3t = ", w3.weights, "\n")
println("w4t = ", w4.weights, "\n")
println("w5t = ", w5.weights, "\n")
println("w6t = ", w6.weights, "\n")
println("w7t = ", w7.weights, "\n")
println("w8t = ", w8.weights, "\n")
println("w9t = ", w9.weights, "\n")
println("w10t = ", w10.weights, "\n")
println("w11t = ", w11.weights, "\n")
println("w12t = ", w12.weights, "\n")
println("w13t = ", w13.weights, "\n")
println("w14t = ", w14.weights, "\n")
println("w15t = ", w15.weights, "\n")
println("w16t = ", w16.weights, "\n")
println("w17t = ", w17.weights, "\n")
println("w18t = ", w18.weights, "\n")
println("w19t = ", w19.weights, "\n")
#######################################

for rtol in [1e-10, 1e-9, 1e-8, 1e-7, 1e-6, 1e-5, 1e-4, 1e-3, 1e-2, 1e-1, 2.5e-1, 5e-1, 1e0]
    a1, a2 = [
        0.010490720965613475,
        0.027638562976896618,
        0.005157935454787538,
        0.014733203690891882,
        0.001093266647285114,
        0.02532695683718382,
        4.1693837439425117e-7,
        0.1342437272400356,
        1.6506785927756833e-6,
        2.097670384814251e-5,
        0.30785405406384075,
        6.251970691408918e-7,
        3.4608589721196204e-7,
        0.12812746072176984,
        1.365011443706727e-6,
        9.210330518075474e-5,
        0.008584753808698897,
        0.20759432127914562,
        2.922717534601414e-6,
        0.12903462967591026,
    ],
    [
        0.011100928247540337,
        0.028797601204028744,
        0.00451697386063243,
        0.015117169787606181,
        0.0003076466235640585,
        0.02549899349018155,
        4.5392069132527076e-7,
        0.13491962123190607,
        1.681770276409214e-6,
        2.0441542555369992e-5,
        0.3061835873256772,
        6.640161273806851e-7,
        3.6474620983326474e-7,
        0.12966556794012535,
        1.4319449667839788e-6,
        0.00012979857147209442,
        0.008064036470981209,
        0.20700779271517056,
        2.9705961760174295e-6,
        0.1286622739941112,
    ]
    if isapprox(a1, a2, rtol = rtol)
        println(", rtol = $(rtol)")
        break
    end
end

portfolio = Portfolio(
    prices = prices,
    solvers = OrderedDict(
        :Clarabel => Dict(
            :solver => Clarabel.Optimizer,
            :params => Dict("verbose" => false, "max_step_fraction" => 0.75),
        ),
        :COSMO => Dict(:solver => COSMO.Optimizer, :params => Dict("verbose" => false)),
    ),
)
asset_statistics!(portfolio)

w1 = opt_port!(
    portfolio;
    rf = rf,
    l = l,
    class = :Classic,
    type = :Trad,
    rm = :Kurt,
    obj = :Min_Risk,
    kelly = :None,
)
risk1 = calc_risk(portfolio; type = :Trad, rm = :Kurt, rf = rf)

rmf = :kurt_u
setproperty!(portfolio, rmf, risk1 + 1e-4 * risk1)
w18 = opt_port!(
    portfolio;
    rf = rf,
    l = l,
    class = :Classic,
    type = :Trad,
    rm = :Kurt,
    obj = :Sharpe,
    kelly = :None,
)

@test isapprox(w18.weights, w1.weights, rtol = 1e-3)

w1 = opt_port!(portfolio; class = :Classic, type = :RP, rm = :Kurt)
rc1 = risk_contribution(portfolio, type = :RP, rm = :Kurt)
lrc1, hrc1 = extrema(rc1)

portfolio.risk_budget = 1:size(portfolio.returns, 2)
w2 = opt_port!(portfolio; class = :Classic, type = :RP, rm = :Kurt)
rc2 = risk_contribution(portfolio, type = :RP, rm = :Kurt)
lrc2, hrc2 = extrema(rc2)

w1t = [
    0.03879158773899491,
    0.04946318916187915,
    0.03767536457743636,
    0.04975768359685481,
    0.03583384747996175,
    0.05474667190193154,
    0.02469826359420486,
    0.10506491736193022,
    0.031245766025529604,
    0.04312788495096333,
    0.12822307815405873,
    0.03170133005454372,
    0.026067725442004967,
    0.057123092045424234,
    0.03137705105386256,
    0.04155724092469867,
    0.044681796838160794,
    0.0754338209703899,
    0.03624092724713855,
    0.057188760880031476,
]

w2t = [
    0.004127710286387879,
    0.010592152386952021,
    0.012536905345418492,
    0.023303462236461917,
    0.01936823663730284,
    0.03214466953862615,
    0.018650835191729918,
    0.08347430641751365,
    0.026201862079995652,
    0.04168068597107915,
    0.1352680942007192,
    0.03614055044122551,
    0.030447496750462644,
    0.07180951106902754,
    0.03968594759203002,
    0.05644735602737195,
    0.07166639041345427,
    0.11896200641502389,
    0.06340744330857792,
    0.10408437769063927,
]

@test isapprox(w1.weights, w1t, rtol = 1.0e-5)
@test isapprox(w2.weights, w2t, rtol = 1.0e-5)
@test isapprox(hrc1 / lrc1, 1, atol = 1.6)
@test isapprox(hrc2 / lrc2, 20, atol = 3.2e0)
