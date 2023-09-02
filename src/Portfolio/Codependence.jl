function _calc_num_bins(xj, xi, j, i, bin_width_func)
    k1 = (maximum(xj) - minimum(xj)) / bin_width_func(xj)
    bins = if j != i
        k2 = (maximum(xi) - minimum(xi)) / bin_width_func(xi)
        Int(round(max(k1, k2)))
    else
        Int(round(k1))
    end
    return bins
end

function _calc_num_bins(N, corr = nothing)
    bins = if isnothing(corr)
        z = cbrt(8 + 324 * N + 12 * sqrt(36 * N + 729 * N^2))
        Int(round(z / 6 + 2 / (3 * z) + 1 / 3))
    else
        Int(round(sqrt(1 + sqrt(1 + 24 * N / (1 - corr^2))) / sqrt(2)))
    end

    return bins
end

function mutualinfo(A::AbstractMatrix{<:Real})
    p_i = vec(sum(A, dims = 2))
    p_j = vec(sum(A, dims = 1))

    length(p_i) == 1 || length(p_j) == 1 && (return 0.0)

    mask = findall(A .!= 0)

    nz = vec(A[mask])
    nz_sum = sum(nz)
    log_nz = log.(nz)
    nz_nm = nz / nz_sum

    outer = p_i[getindex.(mask, 1)] .* p_j[getindex.(mask, 2)]
    log_outer = -log.(outer) .+ log(sum(p_i)) .+ log(sum(p_j))

    mi = (nz_nm .* (log_nz .- log(nz_sum)) .+ nz_nm .* log_outer)
    mi[abs.(mi) .< eps(eltype(mi))] .= 0.0

    return sum(mi)
end

function _calc_hist_data(xj, xi, bins)
    xjl = minimum(xj) - eps(eltype(xj))
    xjh = maximum(xj) + eps(eltype(xj))

    xil = minimum(xi) - eps(eltype(xi))
    xih = maximum(xi) + eps(eltype(xi))

    hx = fit(Histogram, xj, range(xjl, stop = xjh, length = bins + 1)).weights
    hx /= sum(hx)

    hy = fit(Histogram, xi, range(xil, stop = xih, length = bins + 1)).weights
    hy /= sum(hy)

    ex = entropy(hx)
    ey = entropy(hy)

    hxy =
        fit(
            Histogram,
            (xj, xi),
            (
                range(xjl, stop = xjh, length = bins + 1),
                range(xil, stop = xih, length = bins + 1),
            ),
        ).weights

    return ex, ey, hxy
end

function mut_var_info_mtx(x, bins_info = :kn, normed = true)
    @assert(
        bins_info ∈ BinTypes || isa(bins_info, Int),
        "bins has to either be in $BinTypes, or an integer value"
    )

    bin_width_func = if bins_info == :kn
        pyimport("astropy.stats").knuth_bin_width
    elseif bins_info == :fd
        pyimport("astropy.stats").freedman_bin_width
    elseif bins_info == :sc
        pyimport("astropy.stats").scott_bin_width
    end

    T, N = size(x)

    isa(bins_info, Int) && (bins = bins_info)

    mut_mtx = Matrix{eltype(x)}(undef, N, N)
    var_mtx = Matrix{eltype(x)}(undef, N, N)

    for j in 1:N
        xj = x[:, j]
        for i in j:N
            xi = x[:, i]
            bins = if bins_info == :hgr
                corr = cor(xj, xi)
                corr == 1 ? _calc_num_bins(T) : _calc_num_bins(T, corr)
            else
                _calc_num_bins(xj, xi, j, i, bin_width_func)
            end

            ex, ey, hxy = _calc_hist_data(xj, xi, bins)

            mut_ixy = mutualinfo(hxy)
            var_ixy = ex + ey - 2 * mut_ixy
            if normed
                vxy = ex + ey - mut_ixy
                var_ixy = var_ixy / vxy
                mut_ixy /= min(ex, ey)
            end

            (abs(mut_ixy) < eps(typeof(mut_ixy)) || mut_ixy < 0.0) && (mut_ixy = 0.0)
            (abs(var_ixy) < eps(typeof(var_ixy)) || var_ixy < 0.0) && (var_ixy = 0.0)

            mut_mtx[i, j] = mut_ixy
            var_mtx[i, j] = var_ixy
        end
    end

    return Symmetric(mut_mtx, :L), Symmetric(var_mtx, :L)
end

function cordistance(v1::AbstractVector, v2::AbstractVector)
    N = length(v1)
    @assert(
        N == length(v2) && N > 1,
        "lengths of v1 and v2 must be equal and greater than 1"
    )

    N2 = N^2

    a = pairwise(Euclidean(), v1)
    b = pairwise(Euclidean(), v2)
    A = a .- mean(a, dims = 1) .- mean(a, dims = 2) .+ mean(a)
    B = b .- mean(b, dims = 1) .- mean(b, dims = 2) .+ mean(b)

    dcov2_xx = sum(A .* A) / N2
    dcov2_xy = sum(A .* B) / N2
    dcov2_yy = sum(B .* B) / N2

    val = sqrt(dcov2_xy) / sqrt(sqrt(dcov2_xx) * sqrt(dcov2_yy))

    return val
end

function cordistance(x::AbstractMatrix)
    N = size(x, 2)

    mtx = Matrix{eltype(x)}(undef, N, N)
    for j in 1:N
        xj = x[:, j]
        for i in j:N
            mtx[i, j] = cordistance(x[:, i], xj)
        end
    end

    return Symmetric(mtx, :L)
end

function ltdi_mtx(x, alpha = 0.05)
    T, N = size(x)
    k = ceil(Int, T * alpha)
    mtx = Matrix{eltype(x)}(undef, N, N)

    if k > 0
        for j in 1:N
            xj = x[:, j]
            v = sort(xj)[k]
            maskj = xj .<= v
            for i in j:N
                xi = x[:, i]
                u = sort(xi)[k]
                ltd = sum(xi .<= u .&& maskj) / k
                mtx[i, j] = clamp(ltd, 0, 1)
            end
        end
    end

    return Symmetric(mtx, :L)
end

function covgerber1(x, threshold = 0.5; std_func = std, std_args = (), std_kwargs = (;))
    @assert(0 < threshold < 1, "threshold must be greater than zero and smaller than one")

    T, N = size(x)

    std_vec = vec(
        !haskey(std_kwargs, :dims) ? std_func(x, std_args...; dims = 1, std_kwargs...) :
        std_func(x, std_args...; std_kwargs...),
    )

    mtx = Matrix{eltype(x)}(undef, N, N)
    for j in 1:N
        for i in 1:j
            neg = 0
            pos = 0
            nn = 0
            for k in 1:T
                if (
                    (x[k, i] >= threshold * std_vec[i]) &&
                    (x[k, j] >= threshold * std_vec[j])
                ) || (
                    (x[k, i] <= -threshold * std_vec[i]) &&
                    (x[k, j] <= -threshold * std_vec[j])
                )
                    pos += 1
                elseif (
                    (x[k, i] >= threshold * std_vec[i]) &&
                    (x[k, j] <= -threshold * std_vec[j])
                ) || (
                    (x[k, i] <= -threshold * std_vec[i]) &&
                    (x[k, j] >= threshold * std_vec[j])
                )
                    neg += 1
                elseif (
                    abs(x[k, i]) < threshold * std_vec[i] &&
                    abs(x[k, j]) < threshold * std_vec[j]
                )
                    nn += 1
                end
            end
            mtx[i, j] = (pos - neg) / (T - nn)
        end
    end

    mtx .= Symmetric(mtx, :U)

    return mtx .* (std_vec * transpose(std_vec))
end

function covgerber2(x, threshold = 0.5; std_func = std, std_args = (), std_kwargs = (;))
    @assert(0 < threshold < 1, "threshold must be greater than zero and smaller than one")

    T, N = size(x)

    std_vec = vec(
        !haskey(std_kwargs, :dims) ? std_func(x, std_args...; dims = 1, std_kwargs...) :
        std_func(x, std_args...; std_kwargs...),
    )

    U = Matrix{Bool}(undef, T, N)
    D = Matrix{Bool}(undef, T, N)

    for i in 1:N
        U[:, i] .= x[:, i] .>= std_vec[i] * threshold
        D[:, i] .= x[:, i] .<= -std_vec[i] * threshold
    end

    # nconc = transpose(U) * U + transpose(D) * D
    # ndisc = transpose(U) * D + transpose(D) * U
    # H = nconc - ndisc

    UmD = U - D
    H = transpose(U) * UmD - transpose(D) * UmD

    h = sqrt.(diag(H))

    mtx = H ./ (h * transpose(h))

    return mtx .* (std_vec * transpose(std_vec))
end

export covgerber1, covgerber2