
using DataFrames, JuMP

mutable struct Portfolio{
    # Portfolio characteristics
    r,
    s,
    us,
    ul,
    ssl,
    mnea,
    mna,
    rf,
    l,
    # Risk parameters
    ai,
    a,
    as,
    bi,
    b,
    bs,
    k,
    mnak,
    # Benchmark constraints
    to,
    tobw,
    kte,
    te,
    rbi,
    bw,
    # Risk and return constraints
    ami,
    bvi,
    rbv,
    ler,
    ud,
    umad,
    usd,
    ucvar,
    uwr,
    uflpm,
    uslpm,
    umd,
    uad,
    ucdar,
    uuci,
    uevar,
    uedar,
    ugmd,
    utg,
    ur,
    urcvar,
    urtg,
    uk,
    usk,
    urvar,
    urdar,
    # Optimisation model inputs
    tmu,
    tcov,
    tkurt,
    tskurt,
    tl2,
    ts2,
    tmuf,
    tcovf,
    tmufm,
    tcovfm,
    tmubl,
    tcovbl,
    tmublf,
    tcovblf,
    trfm,
    tevar,
    tedar,
    trvar,
    trdar,
    tcovl,
    tcovu,
    tcovmu,
    tcovs,
    tdmu,
    tkmu,
    tks,
    topt,
    trpopt,
    trrpopt,
    twcopt,
    tlim,
    tfront,
    tsolv,
    tsolvp,
    tmod,
    tf,
} <: AbstractPortfolio
    # Portfolio characteristics.
    returns::r
    short::s
    short_u::us
    long_u::ul
    sum_short_long::ssl
    min_number_effective_assets::mnea
    max_number_assets::mna
    returns_factors::rf
    loadings::l
    # Risk parameters.
    alpha_i::ai
    alpha::a
    a_sim::as
    beta_i::bi
    beta::b
    b_sim::bs
    kappa::k
    max_num_assets_kurt::mnak
    # Benchmark constraints.
    turnover::to
    turnover_weights::tobw
    kind_tracking_err::kte
    tracking_err::te
    tracking_err_returns::rbi
    tracking_err_weights::bw
    # Risk and return constraints.
    a_mtx_ineq::ami
    b_vec_ineq::bvi
    risk_budget_vec::rbv
    mu_l::ler
    dev_u::ud
    mad_u::umad
    sdev_u::usd
    cvar_u::ucvar
    wr_u::uwr
    flpm_u::uflpm
    slpm_u::uslpm
    mdd_u::umd
    add_u::uad
    cdar_u::ucdar
    uci_u::uuci
    evar_u::uevar
    edar_u::uedar
    gmd_u::ugmd
    tg_u::utg
    rg_u::ur
    rcvar_u::urcvar
    rtg_u::urtg
    krt_u::uk
    skrt_u::usk
    rvar_u::urvar
    rdar_u::urdar
    # Optimisation model inputs.
    mu::tmu
    cov::tcov
    kurt::tkurt
    skurt::tskurt
    L_2::tl2
    S_2::ts2
    mu_f::tmuf
    cov_f::tcovf
    mu_fm::tmufm
    cov_fm::tcovfm
    mu_bl::tmubl
    cov_bl::tcovbl
    mu_bl_fm::tmublf
    cov_bl_fm::tcovblf
    returns_fm::trfm
    z_evar::tevar
    z_edar::tedar
    z_rvar::trvar
    z_rdar::trdar
    # Inputs of Worst Case Optimization Models.
    cov_l::tcovl
    cov_u::tcovu
    cov_mu::tcovmu
    cov_sigma::tcovs
    d_mu::tdmu
    k_mu::tkmu
    k_sigma::tks
    # Optimal portfolios.
    p_optimal::topt
    rp_optimal::trpopt
    rrp_optimal::trrpopt
    wc_optimal::twcopt
    limits::tlim
    frontier::tfront
    # Solver params.
    solvers::tsolv
    sol_params::tsolvp
    model::tmod
    fail::tf
end

function Portfolio(;
    # Portfolio characteristics.
    returns::DataFrame,
    short::Bool = false,
    short_u::Real = 0.2,
    long_u::Real = 1.0,
    sum_short_long::Real = 1,
    min_number_effective_assets::Integer = 0,
    max_number_assets::Integer = 0,
    returns_factors::DataFrame = DataFrame(),
    loadings::DataFrame = DataFrame(),
    # Risk parameters.
    alpha_i::Real = 0.0001,
    alpha::Real = 0.05,
    a_sim::Integer = 100,
    beta_i::Real = 0.0001,
    beta::Real = Inf,
    b_sim::Integer = -1,
    kappa::Real = 0.3,
    max_num_assets_kurt::Integer = 0,
    # Benchmark constraints.
    turnover::Real = Inf,
    turnover_weights::DataFrame = DataFrame(),
    kind_tracking_err::Symbol = :weights,
    tracking_err::Real = Inf,
    tracking_err_returns::DataFrame = DataFrame(),
    tracking_err_weights::DataFrame = DataFrame(),
    # Risk and return constraints.
    a_mtx_ineq::Matrix{<:Real} = Array{Float64}(undef, 0, 0),
    b_vec_ineq::Vector{<:Real} = Array{Float64}(undef, 0),
    risk_budget_vec::Vector{<:Real} = Array{Float64}(undef, 0),
    mu_l::Real = -Inf,
    dev_u::Real = Inf,
    mad_u::Real = Inf,
    sdev_u::Real = Inf,
    cvar_u::Real = Inf,
    wr_u::Real = Inf,
    flpm_u::Real = Inf,
    slpm_u::Real = Inf,
    mdd_u::Real = Inf,
    add_u::Real = Inf,
    cdar_u::Real = Inf,
    uci_u::Real = Inf,
    evar_u::Real = Inf,
    edar_u::Real = Inf,
    gmd_u::Real = Inf,
    tg_u::Real = Inf,
    rg_u::Real = Inf,
    rcvar_u::Real = Inf,
    rtg_u::Real = Inf,
    krt_u::Real = Inf,
    skrt_u::Real = Inf,
    rvar_u::Real = Inf,
    rdar_u::Real = Inf,
    # Optimisation model inputs.
    mu::Vector{<:Real} = Array{Float64}(undef, 0),
    cov::Matrix{<:Real} = Matrix{Float64}(undef, 0, 0),
    kurt::Matrix{<:Real} = Matrix{Float64}(undef, 0, 0),
    skurt::Matrix{<:Real} = Matrix{Float64}(undef, 0, 0),
    L_2::Matrix{<:Real} = Matrix{Float64}(undef, 0, 0),
    S_2::Matrix{<:Real} = Matrix{Float64}(undef, 0, 0),
    mu_f::Vector{<:Real} = Array{Float64}(undef, 0),
    cov_f::Matrix{<:Real} = Matrix{Float64}(undef, 0, 0),
    mu_fm::Vector{<:Real} = Array{Float64}(undef, 0),
    cov_fm::Matrix{<:Real} = Matrix{Float64}(undef, 0, 0),
    mu_bl::Vector{<:Real} = Array{Float64}(undef, 0),
    cov_bl::Matrix{<:Real} = Matrix{Float64}(undef, 0, 0),
    mu_bl_fm::Vector{<:Real} = Array{Float64}(undef, 0),
    cov_bl_fm::Matrix{<:Real} = Matrix{Float64}(undef, 0, 0),
    returns_fm::DataFrame = DataFrame(),
    z_evar::Real = -Inf,
    z_edar::Real = -Inf,
    z_rvar::Real = -Inf,
    z_rdar::Real = -Inf,
    # Inputs of Worst Case Optimization Models.
    cov_l::Matrix{<:Real} = Matrix{Float64}(undef, 0, 0),
    cov_u::Matrix{<:Real} = Matrix{Float64}(undef, 0, 0),
    cov_mu::Matrix{<:Real} = Matrix{Float64}(undef, 0, 0),
    cov_sigma::Matrix{<:Real} = Matrix{Float64}(undef, 0, 0),
    d_mu::Real = -Inf,
    k_mu::Real = -Inf,
    k_sigma::Real = -Inf,
    # Optimal portfolios.
    p_optimal::DataFrame = DataFrame(),
    rp_optimal::DataFrame = DataFrame(),
    rrp_optimal::DataFrame = DataFrame(),
    wc_optimal::DataFrame = DataFrame(),
    limits::DataFrame = DataFrame(),
    frontier::DataFrame = DataFrame(),
    # Solver params.
    solvers::AbstractDict = Dict(),
    sol_params::AbstractDict = Dict(),
    model = JuMP.Model(),
)
    return Portfolio(
        # Portfolio characteristics.
        returns,
        short,
        short_u,
        long_u,
        sum_short_long,
        min_number_effective_assets,
        max_number_assets,
        returns_factors,
        loadings,
        # Risk parameters.
        alpha_i,
        alpha,
        a_sim,
        beta_i,
        beta,
        b_sim,
        kappa,
        max_num_assets_kurt,
        # Benchmark constraints.
        turnover,
        turnover_weights,
        kind_tracking_err,
        tracking_err,
        tracking_err_returns,
        tracking_err_weights,
        # Risk and return constraints.
        a_mtx_ineq,
        b_vec_ineq,
        risk_budget_vec,
        mu_l,
        dev_u,
        mad_u,
        sdev_u,
        cvar_u,
        wr_u,
        flpm_u,
        slpm_u,
        mdd_u,
        add_u,
        cdar_u,
        uci_u,
        evar_u,
        edar_u,
        gmd_u,
        tg_u,
        rg_u,
        rcvar_u,
        rtg_u,
        krt_u,
        skrt_u,
        rvar_u,
        rdar_u,
        # Optimisation model inputs.
        mu,
        cov,
        kurt,
        skurt,
        L_2,
        S_2,
        mu_f,
        cov_f,
        mu_fm,
        cov_fm,
        mu_bl,
        cov_bl,
        mu_bl_fm,
        cov_bl_fm,
        returns_fm,
        z_evar,
        z_edar,
        z_rvar,
        z_rdar,
        # Inputs of Worst Case Optimization Models.
        cov_l,
        cov_u,
        cov_mu,
        cov_sigma,
        d_mu,
        k_mu,
        k_sigma,
        # Optimal portfolios.
        p_optimal,
        rp_optimal,
        rrp_optimal,
        wc_optimal,
        limits,
        frontier,
        # Solver params.
        solvers,
        sol_params,
        model,
        Dict(),
    )
end

# Risk constants and functions.
include("_portfolio_risk_setup.jl")
# Optimisation functions.
include("_portfolio_optim_setup.jl")

function optimize(
    portfolio::Portfolio;
    class::Symbol = :classic,
    rm::Symbol = :mv,
    obj::Symbol = :sharpe,
    kelly::Symbol = :none,
    rf::Real = 1.0329^(1 / 252) - 1,
    l::Real = 2.0,
    string_names = false,
)
    @assert(class ∈ PortClasses, "class must be one of $PortClasses")
    @assert(rm ∈ RiskMeasures, "rm must be one of $RiskMeasures")
    @assert(obj ∈ ObjFuncs, "obj must be one of $ObjFuncs")
    @assert(kelly ∈ KellyRet, "kelly must be one of $KellyRet")
    @assert(
        portfolio.kind_tracking_err ∈ TrackingErrKinds,
        "portfolio.kind_tracking_err must be one of $TrackingErrKinds"
    )

    portfolio.model = JuMP.Model()

    # Returns, mu, covariance.
    returns = Matrix(portfolio.returns[!, 2:end])
    T, N = size(returns)
    mu = portfolio.mu
    sigma = portfolio.cov

    if (rm == :rvar || rm == :rdar)
        alpha = portfolio.alpha
        kappa = portfolio.kappa
        c = 1 / (alpha * T)
        ln_k = (c^kappa - c^(-kappa)) / (2 * kappa)
    else
        ln_k = 0
    end

    # Model variables.
    model = portfolio.model
    set_string_names_on_creation(model, string_names)

    @variable(model, w[1:N])
    @variable(model, k >= 0)

    # Risk variables, functions and constraints.
    ## Mean variance.
    _mv_setup(portfolio, sigma, rm, kelly, obj)
    ## Mean Absolute Deviation and Mean Semi Deviation.
    _mad_setup(portfolio, rm, T, returns, mu, obj)
    ## Conditional and Entropic Value at Risk
    _var_setup(portfolio, rm, T, returns, obj, ln_k)
    ## Worst realisation.
    _wr_setup(portfolio, rm, returns, obj)
    ## Lower partial moments, Omega and Sortino ratios.
    _lpm_setup(portfolio, rm, T, returns, obj, rf)
    ## Drawdown, Max Drawdown, Average Drawdown, Conditional Drawdown, Ulcer Index, Entropic Drawdown at Risk
    _drawdown_setup(portfolio, rm, T, returns, obj, ln_k)
    ## OWA methods
    _owa_setup(portfolio, rm, T, returns, obj)

    # Constraints.
    ## Return variables.
    _return_setup(portfolio, class, kelly, obj, T, rf, returns, mu)
    ## Weight constraints.
    _setup_weights(portfolio, obj, N)
    ## Linear weight constraints.
    _setup_linear_constraints(portfolio, obj)
    ## Minimum number of effective assets.
    _setup_min_number_effective_assets(portfolio, obj)
    ## Tracking error variables and constraints.
    _setup_tracking_err(portfolio, returns, obj, T)
    ## Turnover variables and constraints
    _setup_turnover(portfolio, N, obj)

    # Objective functions.
    _setup_objective_function(portfolio, obj, kelly, l)

    # Optimize.
    term_status, solvers_tried = _optimize_portfolio(portfolio, N)

    # Error handling.
    if term_status ∉ ValidTermination || any(.!isfinite.(value.(w)))
        funcname = "$(fullname(PortfolioOptimiser)[1]).$(nameof(PortfolioOptimiser.optimize))"

        @warn(
            "$funcname: model could not be optimised satisfactorily.\nPortfolio: $class\nRisk measure: $rm\nKelly return: $kelly\nObjective: $obj\nSolvers: $solvers_tried"
        )

        portfolio.p_optimal = DataFrame()
        portfolio.fail = solvers_tried

        return portfolio.p_optimal
    end

    # Cleanup.
    _cleanup_weights(portfolio, returns, N, obj, solvers_tried)

    return portfolio.p_optimal
end

export AbstractPortfolio, Portfolio, optimize#, HCPortfolio, OWAPortfolio