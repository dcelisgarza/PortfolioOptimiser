abstract type AbstractPortfolio end
mutable struct Portfolio{
    # Portfolio characteristics
    ast,
    dat,
    r,
    s,
    us,
    ul,
    ssl,
    mnea,
    mna,
    mnaf,
    tfa,
    tfdat,
    tretf,
    l,
    # Risk parameters
    msvt,
    lpmt,
    ai,
    a,
    as,
    tat,
    bi,
    b,
    bs,
    k,
    tiat,
    lnk,
    topk,
    tomk,
    tk2,
    tkinv,
    tinvopk,
    tinvomk,
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
    uowa,
    wowa,
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
    tf,
    toptpar,
    tmod,
} <: AbstractPortfolio
    # Portfolio characteristics.
    assets::ast
    timestamps::dat
    returns::r
    short::s
    short_u::us
    long_u::ul
    sum_short_long::ssl
    min_number_effective_assets::mnea
    max_number_assets::mna
    max_number_assets_factor::mnaf
    f_assets::tfa
    f_timestamps::tfdat
    f_returns::tretf
    loadings::l
    # Risk parameters.
    msv_target::msvt
    lpm_target::lpmt
    alpha_i::ai
    alpha::a
    a_sim::as
    at::tat
    beta_i::bi
    beta::b
    b_sim::bs
    kappa::k
    invat::tiat
    ln_k::lnk
    opk::topk
    omk::tomk
    invkappa2::tk2
    invk::tkinv
    invopk::tinvopk
    invomk::tinvomk
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
    risk_budget::rbv
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
    owa_u::uowa
    owa_w::wowa
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
    opt_params::toptpar
    fail::tf
    model::tmod
end

function Portfolio(;
    # Portfolio characteristics.
    returns = DataFrame(),
    short::Bool = false,
    short_u::Real = 0.2,
    long_u::Real = 1.0,
    sum_short_long::Real = 1,
    min_number_effective_assets::Integer = 0,
    max_number_assets::Integer = 0,
    max_number_assets_factor::Real = 100_000,
    f_returns = DataFrame(),
    loadings = Matrix{Float64}(undef, 0, 0),
    # Risk parameters.
    msv_target = Inf,
    lpm_target = Inf,
    alpha_i::Real = 0.0001,
    alpha::Real = 0.05,
    a_sim::Integer = 100,
    beta_i::Real = Inf,
    beta::Real = Inf,
    b_sim::Integer = -1,
    kappa::Real = 0.3,
    max_num_assets_kurt::Integer = 0,
    # Benchmark constraints.
    turnover::Real = Inf,
    turnover_weights = Vector{Float64}(undef, 0),
    kind_tracking_err::Symbol = :weights,
    tracking_err::Real = Inf,
    tracking_err_returns = Vector{Float64}(undef, 0),
    tracking_err_weights = Vector{Float64}(undef, 0),
    # Risk and return constraints.
    a_mtx_ineq = Matrix{Float64}(undef, 0, 0),
    b_vec_ineq = Vector{Float64}(undef, 0),
    risk_budget = Vector{Float64}(undef, 0),
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
    owa_u::Real = Inf,
    owa_w = Vector{Float64}(undef, 0),
    krt_u::Real = Inf,
    skrt_u::Real = Inf,
    rvar_u::Real = Inf,
    rdar_u::Real = Inf,
    # Optimisation model inputs.
    mu = Vector{Float64}(undef, 0),
    cov = Matrix{Float64}(undef, 0, 0),
    kurt = Matrix{Float64}(undef, 0, 0),
    skurt = Matrix{Float64}(undef, 0, 0),
    L_2 = SparseMatrixCSC{Float64, Int}(undef, 0, 0),
    S_2 = SparseMatrixCSC{Float64, Int}(undef, 0, 0),
    mu_f = Vector{Float64}(undef, 0),
    cov_f = Matrix{Float64}(undef, 0, 0),
    mu_fm = Vector{Float64}(undef, 0),
    cov_fm = Matrix{Float64}(undef, 0, 0),
    mu_bl = Vector{Float64}(undef, 0),
    cov_bl = Matrix{Float64}(undef, 0, 0),
    mu_bl_fm = Vector{Float64}(undef, 0),
    cov_bl_fm = Matrix{Float64}(undef, 0, 0),
    returns_fm = Matrix{Float64}(undef, 0, 0),
    z_evar::Real = -Inf,
    z_edar::Real = -Inf,
    z_rvar::Real = -Inf,
    z_rdar::Real = -Inf,
    # Inputs of Worst Case Optimization Models.
    cov_l = Matrix{Float64}(undef, 0, 0),
    cov_u = Matrix{Float64}(undef, 0, 0),
    cov_mu = Diagonal{Float64}(undef, 0),
    cov_sigma = Diagonal{Float64}(undef, 0),
    d_mu = Vector{Float64}(undef, 0),
    k_mu::Real = -Inf,
    k_sigma::Real = -Inf,
    # Optimal portfolios.
    p_optimal = DataFrame(),
    rp_optimal = DataFrame(),
    rrp_optimal = DataFrame(),
    wc_optimal = DataFrame(),
    limits = Matrix{Float64}(undef, 0, 0),
    frontier = Matrix{Float64}(undef, 0, 0),
    # Solutions.
    solvers::AbstractDict = Dict(),
    opt_params::AbstractDict = Dict(),
    fail::AbstractDict = Dict(),
    model = JuMP.Model(),
)
    assets = names(returns)[2:end]
    timestamps = returns[!, 1]
    returns = Matrix(returns[!, 2:end])

    if !isempty(f_returns)
        f_assets = names(f_returns)[2:end]
        f_timestamps = f_returns[!, 1]
        f_returns = Matrix(f_returns[!, 2:end])
    else
        f_assets = Vector{String}(undef, 0)
        f_timestamps = Vector{Date}(undef, 0)
        f_returns = Matrix{eltype(returns)}(undef, 0, 0)
    end

    return Portfolio(
        # Portfolio characteristics.
        assets,
        timestamps,
        returns,
        short,
        short_u,
        long_u,
        sum_short_long,
        min_number_effective_assets,
        max_number_assets,
        max_number_assets_factor,
        f_assets,
        f_timestamps,
        f_returns,
        loadings,
        # Risk parameters.
        msv_target,
        lpm_target,
        alpha_i,
        alpha,
        a_sim,
        zero(typeof(alpha)),
        beta_i,
        beta,
        b_sim,
        kappa,
        zero(typeof(kappa)),
        zero(typeof(kappa)),
        zero(typeof(kappa)),
        zero(typeof(kappa)),
        zero(typeof(kappa)),
        zero(typeof(kappa)),
        zero(typeof(kappa)),
        zero(typeof(kappa)),
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
        risk_budget,
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
        owa_u,
        owa_w,
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
        # Solutions.
        solvers,
        opt_params,
        fail,
        model,
    )
end

mutable struct HCPortfolio{
    ast,
    dat,
    r,
    ai,
    a,
    as,
    tat,
    bi,
    b,
    bs,
    k,
    tiat,
    lnk,
    topk,
    tomk,
    tk2,
    tkinv,
    tinvopk,
    tinvomk,
    ata,
    gst,
    tmu,
    tcov,
    tbin,
    ao,
    so,
    tco,
    tcor,
    tcl,
    wmi,
    wma,
    tsolv,
    toptpar,
    tf,
} <: AbstractPortfolio
    # Portfolio characteristics.
    assets::ast
    timestamps::dat
    returns::r
    # Risk parmeters.
    alpha_i::ai
    alpha::a
    a_sim::as
    at::tat
    beta_i::bi
    beta::b
    b_sim::bs
    kappa::k
    invat::tiat
    ln_k::lnk
    opk::topk
    omk::tomk
    invkappa2::tk2
    invk::tkinv
    invopk::tinvopk
    invomk::tinvomk
    alpha_tail::ata
    gs_threshold::gst
    # Optimisation parameters.
    mu::tmu
    cov::tcov
    bins::tbin
    w_min::wmi
    w_max::wma
    # Optimisation results.
    asset_order::ao
    sort_order::so
    codep::tco
    codep_order::tcor
    clusters::tcl
    # Solutions.
    solvers::tsolv
    opt_params::toptpar
    fail::tf
end

function HCPortfolio(;
    # Portfolio characteristics.
    returns = DataFrame(),
    # Risk parmeters.
    alpha_i::Real = 0.0001,
    alpha::Real = 0.05,
    a_sim::Integer = 100,
    beta_i::Real = Inf,
    beta::Real = Inf,
    b_sim::Integer = -1,
    kappa::Real = 0.3,
    alpha_tail::Real = 0.05,
    gs_threshold::Real = 0.5,
    # Optimisation parameters.
    mu = Vector{Float64}(undef, 0),
    cov = Matrix{Float64}(undef, 0, 0),
    bins = :kn,
    w_min = Vector{Float64}(undef, 0),
    w_max = Vector{Float64}(undef, 0),
    # Optimisation results.
    asset_order = Vector{Float64}(undef, 0),
    sort_order = Vector{Float64}(undef, 0),
    codep = Vector{Float64}(undef, 0),
    codep_order = Vector{Float64}(undef, 0),
    clusters = Vector{Vector{Float64}}(undef, 0),
    # Solutions.
    solvers::AbstractDict = Dict(),
    opt_params::AbstractDict = Dict(),
    fail::AbstractDict = Dict(),
)
    assets = names(returns)[2:end]
    timestamps = returns[!, 1]
    returns = Matrix(returns[!, 2:end])

    return HCPortfolio(
        # Portfolio characteristics.
        assets,
        timestamps,
        returns,
        alpha_i,
        alpha,
        a_sim,
        zero(typeof(kappa)),
        beta_i,
        beta,
        b_sim,
        kappa,
        zero(typeof(kappa)),
        zero(typeof(kappa)),
        zero(typeof(kappa)),
        zero(typeof(kappa)),
        zero(typeof(kappa)),
        zero(typeof(kappa)),
        zero(typeof(kappa)),
        zero(typeof(kappa)),
        alpha_tail,
        gs_threshold,
        # Optimisation parameters.
        mu,
        cov,
        bins,
        w_min,
        w_max,
        # Optimisation results.
        asset_order,
        sort_order,
        codep,
        codep_order,
        clusters,
        # Solutions.
        solvers,
        opt_params,
        fail,
    )
end

export AbstractPortfolio, Portfolio, HCPortfolio