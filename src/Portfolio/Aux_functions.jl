
function gen_dataframes(portfolio)
    nms = portfolio.assets
    nms2 = vec(["$(i)-$(j)" for i in nms, j in nms])

    df_returns = hcat(
        DataFrame(timestamp = portfolio.timestamps),
        DataFrame(portfolio.returns, portfolio.assets),
    )
    df_mu = DataFrame(ticker = nms, val = portfolio.mu)
    df_cov = DataFrame(portfolio.cov, nms)
    df_kurt = DataFrame(portfolio.kurt, nms2)
    df_skurt = DataFrame(portfolio.skurt, nms2)

    df_cov_l = DataFrame(portfolio.cov_l, nms)
    df_cov_u = DataFrame(portfolio.cov_u, nms)
    df_cov_mu = DataFrame(portfolio.cov_mu, nms)
    df_cov_sigma = DataFrame(portfolio.cov_sigma, nms2)
    df_dmu = DataFrame(ticker = nms, val = portfolio.d_mu)

    return df_returns,
    df_mu,
    df_cov,
    df_kurt,
    df_skurt,
    df_cov_l,
    df_cov_u,
    df_cov_mu,
    df_cov_sigma,
    df_dmu
end

function block_vec_pq(A, p, q)
    mp, nq = size(A)

    !(mod(mp, p) == 0 && mod(nq, p) == 0) && (throw(
        DimensionMismatch(
            "dimensions A, $(size(A)), must be integer multiples of (p, q) = ($p, $q)",
        ),
    ))

    m = Int(mp / p)
    n = Int(nq / q)

    A_vec = Matrix{eltype(A)}(undef, m * n, p * q)
    for j in 0:(n - 1)
        Aj = Matrix{eltype(A)}(undef, m, p * q)
        for i in 0:(m - 1)
            Aij = vec(A[(1 + (i * p)):((i + 1) * p), (1 + (j * q)):((j + 1) * q)])
            Aj[i + 1, :] .= Aij
        end
        A_vec[(1 + (j * m)):((j + 1) * m), :] .= Aj
    end

    return A_vec
end

function commutation_matrix(x::AbstractMatrix)
    m, n = size(x)
    mn = m * n
    row = 1:mn
    col = vec(transpose(reshape(row, m, n)))
    data = range(start = 1, stop = 1, length = mn)
    com = sparse(row, col, data, mn, mn)
    return com
end

function cov_returns(x; seed = nothing, rng = Random.default_rng(), len = 10, iters = 5)
    !isnothing(seed) && Random.seed!(rng, seed)

    n = size(x)[1]
    a = randn(rng, n + len, n)

    for _ in 1:iters
        _cov = cov(a)
        _C = cholesky(_cov)
        a .= transpose(_C.L \ transpose(a))
        _cov = cov(a)
        _desv = transpose(sqrt.(diag(_cov)))
        a .= (a .- mean(a, dims = 1)) ./ _desv
    end

    C = cholesky(x)
    return a * C.U
end

function duplication_matrix(n::Int)
    cols = Int(n * (n + 1) / 2)
    rows = n * n
    mtx = spzeros(rows, cols)
    for j in 1:n
        for i in j:n
            u = spzeros(1, cols)
            col = Int((j - 1) * n + i - (j * (j - 1)) / 2)
            u[col] = 1
            T = spzeros(n, n)
            T[i, j] = 1
            T[j, i] = 1
            mtx .+= vec(T) * u
        end
    end
    return mtx
end

function elimination_matrix(n::Int)
    rows = Int(n * (n + 1) / 2)
    cols = n * n
    mtx = spzeros(rows, cols)
    for j in 1:n
        ej = spzeros(1, n)
        ej[j] = 1
        for i in j:n
            u = spzeros(rows)
            row = Int((j - 1) * n + i - (j * (j - 1)) / 2)
            u[row] = 1
            ei = spzeros(1, n)
            ei[i] = 1
            mtx .+= kron(u, kron(ej, ei))
        end
    end
    return mtx
end

function summation_matrix(n::Int)
    d = duplication_matrix(n)
    l = elimination_matrix(n)

    s = transpose(d) * d * l

    return s
end

function dup_elim_sum_matrices(n::Int)
    d = duplication_matrix(n)
    l = elimination_matrix(n)
    s = transpose(d) * d * l

    return d, l, s
end

const KindBootstrap = (:stationary, :circular, :moving)
function gen_bootstrap(
    returns,
    kind,
    n_sim,
    window = 3,
    seed = nothing,
    rng = Random.default_rng(),
)
    @assert(kind ∈ KindBootstrap, "kind must be one of $KindBootstrap")
    !isnothing(seed) && Random.seed!(rng, seed)

    mus = nothing
    covs = nothing

    return mus, covs
end

const BinTypes = (:kn, :fd, :sc, :hgr)
function _calc_num_bins(x, j, i, bin_width_func)
    k1 = (maximum(x[:, j]) - minimum(x[:, j])) / bin_width_func(x[:, j])
    bins = if j != i
        k2 = (maximum(x[:, i]) - minimum(x[:, i])) / bin_width_func(x[:, i])
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
end

const InfoTypes = (:variation, :mutual)
function info_mtx(x, bins_info = :kn, type_info = :mutual, normed = true)
    @assert(
        bins_info ∈ BinTypes || isa(bins_info, Int),
        "bins has to either be in $BinTypes, or an integer value"
    )
    @assert(type_info ∈ InfoTypes, "type_info must be in $InfoTypes")

    bin_width_func = if bins_info == :kn
        pyimport("astropy.stats").knuth_bin_width
    elseif bins_info == :fd
        pyimport("astropy.stats").freedman_bin_width
    elseif bins_info == :sc
        pyimport("astropy.stats").scott_bin_width
    end

    T, N = size(x)

    mtx = zeros(N, N)
    for j in 1:N, i in j:N
        bins = if isa(bins_info, Int)
            bins_info
        elseif bins_info == :hgr
            corr = cor(x[:, j], x[:, i])
            corr == 1 ? _calc_num_bins(T) : _calc_num_bins(T, corr)
        else
            _calc_num_bins(x, j, i, bin_width_func)
        end

        hx = fit(Histogram, x[:, j], nbins = bins).weights
        hy = fit(Histogram, x[:, i], nbins = bins).weights
        ixy = type_info == :mutual ? mutualinfo(hx, hy, normed = normed) : varinfo(hx, hy)

        mtx[i, j] = clamp(ixy, 0, Inf)
    end

    return Symmetric(mtx, :L)
end

export gen_dataframes,
    block_vec_pq,
    commutation_matrix,
    cov_returns,
    duplication_matrix,
    elimination_matrix,
    summation_matrix,
    dup_elim_sum_matrices,
    gen_bootstrap

N = 5
mtx = zeros(N, N)
for j in 1:N, i in j:N
    mtx[i, j] = 1
end