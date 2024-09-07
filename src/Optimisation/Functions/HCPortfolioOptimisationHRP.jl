function _optimise!(::HRP, port::HCPortfolio, rm::Union{AbstractVector, <:RiskMeasure},
                    ::Any, w_min, w_max)
    N = size(port.returns, 2)
    weights = ones(eltype(port.returns), N)
    items = [port.clusters.order]

    while length(items) > 0
        items = [i[j:k] for i ∈ items
                 for (j, k) ∈ ((1, div(length(i), 2)), (1 + div(length(i), 2), length(i)))
                 if length(i) > 1]

        for i ∈ 1:2:length(items)
            lc = items[i]
            rc = items[i + 1]
            lrisk = zero(eltype(weights))
            rrisk = zero(eltype(weights))
            for r ∈ rm
                solver_flag = false
                if hasproperty(r, :solvers) && (isnothing(r.solvers) || isempty(r.solvers))
                    r.solvers = port.solvers
                    solver_flag = true
                end
                scale = r.settings.scale
                # Left risk.
                lrisk += cluster_risk(port, lc, r) * scale
                # Right risk.
                rrisk += cluster_risk(port, rc, r) * scale
                if solver_flag
                    r.solvers = nothing
                end
            end
            # Allocate weight to clusters.
            alpha_1 = one(lrisk) - lrisk / (lrisk + rrisk)
            # Weight constraints.
            alpha_1 = cluster_weight_bounds(w_min, w_max, weights, lc, rc, alpha_1)
            weights[lc] *= alpha_1
            weights[rc] *= one(alpha_1) - alpha_1
        end
    end
    return weights
end