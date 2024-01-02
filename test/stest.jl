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

cols = [:RRC, :AMZN, :JPM, :MA, :WMT]
PortfolioOptimiser.MuTypes
PortfolioOptimiser.MuTargets

println("mut = ", portfolio.mu)
println("covt = reshape(", vec(portfolio.cov), ", 20, 20)")

# println("kurtt = reshape(", vec(portfolio.kurt), ", 5^2, 5^2)")
# println("skurtt = reshape(", vec(portfolio.skurt), ", 5^2, 5^2)")

asset_statistics!(
    portfolio::AbstractPortfolio;
    # # flags
    # calc_codep::Bool = true,
    # calc_cov::Bool = true,
    # calc_mu::Bool = true,
    # calc_kurt::Bool = true,
    # # cov_mtx
    # alpha::Real = 0.0,
    # cov_args::Tuple = (),
    # cov_est::CovarianceEstimator = StatsBase.SimpleCovariance(; corrected = true),
    # cov_func::Function = cov,
    # cov_kwargs::NamedTuple = (;),
    # cov_type::Symbol = portfolio.cov_type,
    # cov_weights::Union{AbstractWeights, Nothing} = nothing,
    # custom_cov::Union{AbstractMatrix, Nothing} = nothing,
    # denoise::Bool = false,
    # detone::Bool = false,
    # gs_threshold::Real = portfolio.gs_threshold,
    # jlogo::Bool = portfolio.jlogo,
    # kernel = ASH.Kernels.gaussian,
    # m::Integer = 10,
    # method::Symbol = :Fixed,
    # mkt_comp::Integer = 0,
    # n::Integer = 1000,
    # opt_args = (),
    # opt_kwargs = (;),
    # posdef_args::Tuple = (),
    # posdef_fix::Symbol = portfolio.posdef_fix,
    # posdef_func::Function = x -> x,
    # posdef_kwargs::NamedTuple = (;),
    # std_args::Tuple = (),
    # std_func::Function = std,
    # std_kwargs::NamedTuple = (;),
    # target_ret::Union{Real, AbstractVector{<:Real}} = 0.0,
    # # mean_vec
    # custom_mu::Union{AbstractVector, Nothing} = nothing,
    # mean_args::Tuple = (),
    # mean_func::Function = mean,
    # mean_kwargs::NamedTuple = (;),
    # mkt_ret::Union{AbstractVector, Nothing} = nothing,
    # mu_target::Symbol = :GM,
    # mu_type::Symbol = portfolio.mu_type,
    # mu_weights::Union{AbstractWeights, Nothing} = nothing,
    # rf::Real = 0.0,
    # # codep_dist_mtx
    # alpha_tail::Union{Real, Nothing} = isa(portfolio, HCPortfolio) ? portfolio.alpha_tail :
    #                                    nothing,
    # bins_info::Union{Symbol, Integer, Nothing} = isa(portfolio, HCPortfolio) ?
    #                                              portfolio.bins_info : nothing,
    # codep_type::Union{Symbol, Nothing} = isa(portfolio, HCPortfolio) ?
    #                                      portfolio.codep_type : nothing,
    # cor_args::Tuple = (),
    # cor_func::Function = cor,
    # cor_kwargs::NamedTuple = (;),
    # custom_cor::Union{AbstractMatrix, Nothing} = nothing,
    # dist_args::Tuple = (),
    # dist_func::Function = x -> sqrt.(clamp!((1 .- x) / 2, 0, 1)),
    # dist_kwargs::NamedTuple = (;),
    # custom_kurt::Union{AbstractMatrix, Nothing} = nothing,
    # custom_skurt::Union{AbstractMatrix, Nothing} = nothing,
    # uplo::Symbol = :L,
)

########################################
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
    ],
    [
        0.004127705244176058,
        0.010592144373129499,
        0.012536891784237078,
        0.02330345222822044,
        0.01936822351841273,
        0.03214462073915424,
        0.01865081904161745,
        0.08347415403836461,
        0.02620187861704772,
        0.04168059442187793,
        0.1352683515063191,
        0.036140539854211735,
        0.030447429468590907,
        0.07180915217718357,
        0.039685906039658984,
        0.05644733649337989,
        0.07166656725011773,
        0.11896275408544081,
        0.06340706674511927,
        0.10408441237374016,
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
