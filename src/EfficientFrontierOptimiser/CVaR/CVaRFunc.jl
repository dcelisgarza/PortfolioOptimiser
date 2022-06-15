function min_cvar!(
    portfolio::EfficientCVaR;
    optimiser = Ipopt.Optimizer,
    silent = true,
    optimiser_attributes = (),
)
    termination_status(portfolio.model) != OPTIMIZE_NOT_CALLED && refresh_model!(portfolio)

    model = portfolio.model

    alpha = model[:alpha]
    u = model[:u]
    beta = portfolio.beta
    samples = size(portfolio.returns, 1)
    @objective(model, Min, cvar(alpha, u, samples, beta))

    # Add extra terms to objective function.
    extra_obj_terms = portfolio.extra_obj_terms
    if !isempty(extra_obj_terms)
        _add_to_objective!.(model, extra_obj_terms)
    end

    _setup_and_optimise(model, optimiser, silent, optimiser_attributes)

    w = model[:w]
    portfolio.weights .= value.(w)

    return portfolio
end

function max_sharpe!(
    portfolio::EfficientCVaR,
    rf = portfolio.rf;
    optimiser = Ipopt.Optimizer,
    silent = true,
    optimiser_attributes = (),
)
    termination_status(portfolio.model) != OPTIMIZE_NOT_CALLED && throw(
        ArgumentError(
            "Max sharpe uses a variable transformation that changes the constraints and objective function. Please create a new instance instead.",
        ),
    )

    rf = _val_compare_benchmark(rf, <=, 0, 0.02, "rf")
    # _function_vs_portfolio_val_warn(rf, portfolio.rf, "rf")

    model = portfolio.model

    # We need a new variable for max_sharpe_optim.
    @variable(model, k)

    _transform_constraints_sharpe(model, k)

    # Add constraints for the transformed sharpe ratio.
    w = model[:w]
    # We have to ensure k is positive.
    @constraint(model, k_positive, k >= 0)

    mean_ret = portfolio.mean_ret
    # Since we increased the unbounded the sum of the weights to potentially be as large as k, leave this be. Equation 8.13 in the pdf linked in docs.
    port_ret = port_return(w, mean_ret)
    @constraint(model, max_sharpe_return, port_ret - rf * k == 1)

    # Objective function.
    alpha = model[:alpha]
    u = model[:u]
    beta = portfolio.beta
    samples = size(portfolio.returns, 1)
    @objective(model, Min, cvar(alpha, u, samples, beta))

    # Add extra terms to objective function.
    extra_obj_terms = portfolio.extra_obj_terms
    if !isempty(extra_obj_terms)
        @warn(
            "Sharpe ratio optimisation uses a variable transformation which means extra objective terms may not behave as expected. Use custom_nloptimiser if extra objective terms are needed.",
        )
        _add_to_objective!.(model, extra_obj_terms)
    end

    _setup_and_optimise(model, optimiser, silent, optimiser_attributes)

    portfolio.weights .= value.(w) / value(k)

    return nothing
end

function efficient_return!(
    portfolio::EfficientCVaR,
    target_ret = portfolio.target_ret;
    optimiser = Ipopt.Optimizer,
    silent = true,
    optimiser_attributes = (),
)
    termination_status(portfolio.model) != OPTIMIZE_NOT_CALLED && refresh_model!(portfolio)

    mean_ret = portfolio.mean_ret
    max_ret = maximum(mean_ret)

    correction = max(max_ret / 2, 0)
    # _function_vs_portfolio_val_warn(target_ret, portfolio.target_ret, "target_ret")
    target_ret = _val_compare_benchmark(target_ret, >, max_ret, correction, "target_ret")
    target_ret = _val_compare_benchmark(target_ret, <, 0, correction, "target_ret")

    model = portfolio.model

    w = model[:w]

    @constraint(model, target_ret, port_return(w, mean_ret) >= target_ret)

    alpha = model[:alpha]
    u = model[:u]
    beta = portfolio.beta
    samples = size(portfolio.returns, 1)
    @objective(model, Min, cvar(alpha, u, samples, beta))

    # Add extra terms to objective function.
    extra_obj_terms = portfolio.extra_obj_terms
    if !isempty(extra_obj_terms)
        _add_to_objective!.(model, extra_obj_terms)
    end

    _setup_and_optimise(model, optimiser, silent, optimiser_attributes)

    portfolio.weights .= value.(w)

    return portfolio
end

function efficient_risk!(
    portfolio::EfficientCVaR,
    target_cvar = portfolio.target_cvar;
    optimiser = Ipopt.Optimizer,
    silent = true,
    optimiser_attributes = (),
)
    termination_status(portfolio.model) != OPTIMIZE_NOT_CALLED && refresh_model!(portfolio)

    # _function_vs_portfolio_val_warn(target_cvar, portfolio.target_cvar, "target_cvar")
    target_cvar = _val_compare_benchmark(
        target_cvar,
        <,
        0,
        max(mean(maximum(portfolio.returns, dims = 2)), 0),
        "target_cvar",
    )

    model = portfolio.model
    alpha = model[:alpha]
    u = model[:u]
    beta = portfolio.beta
    samples = size(portfolio.returns, 1)
    @constraint(model, target_cvar, cvar(alpha, u, samples, beta) <= target_cvar)

    w = model[:w]
    mean_ret = portfolio.mean_ret
    @objective(model, Min, -port_return(w, mean_ret))

    # Add extra terms to objective function.
    extra_obj_terms = portfolio.extra_obj_terms
    if !isempty(extra_obj_terms)
        _add_to_objective!.(model, extra_obj_terms)
    end

    _setup_and_optimise(model, optimiser, silent, optimiser_attributes)

    portfolio.weights .= value.(w)

    return portfolio
end

function max_quadratic_utility!(
    portfolio::EfficientCVaR,
    risk_aversion = portfolio.risk_aversion;
    optimiser = Ipopt.Optimizer,
    silent = true,
    optimiser_attributes = (),
)
    termination_status(portfolio.model) != OPTIMIZE_NOT_CALLED && refresh_model!(portfolio)

    # _function_vs_portfolio_val_warn(risk_aversion, portfolio.risk_aversion, "risk_aversion")
    risk_aversion = _val_compare_benchmark(risk_aversion, <=, 0, 1, "risk_aversion")

    model = portfolio.model

    w = model[:w]
    alpha = model[:alpha]
    u = model[:u]
    beta = portfolio.beta
    samples = size(portfolio.returns, 1)

    mean_ret = portfolio.mean_ret

    μ = port_return(w, mean_ret)# / (samples * (1 - beta))

    @objective(model, Min, -μ + 0.5 * risk_aversion * cvar(alpha, u, samples, beta))

    # Add extra terms to objective function.
    extra_obj_terms = portfolio.extra_obj_terms
    if !isempty(extra_obj_terms)
        _add_to_objective!.(model, extra_obj_terms)
    end

    _setup_and_optimise(model, optimiser, silent, optimiser_attributes)

    portfolio.weights .= value.(w)

    return nothing
end