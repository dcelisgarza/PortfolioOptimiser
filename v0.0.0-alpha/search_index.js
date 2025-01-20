var documenterSearchIndex = {"docs":
[{"location":"References/#References","page":"References","title":"References","text":"","category":"section"},{"location":"References/","page":"References","title":"References","text":"","category":"page"},{"location":"RiskMeasures/#Risk-Measures","page":"Risk Measures","title":"Risk Measures","text":"","category":"section"},{"location":"RiskMeasures/#Public","page":"Risk Measures","title":"Public","text":"","category":"section"},{"location":"RiskMeasures/","page":"Risk Measures","title":"Risk Measures","text":"Modules = [PortfolioOptimiser]\nPublic = true\nPrivate = false\nPages = [\"RiskMeasures.jl\"]","category":"page"},{"location":"RiskMeasures/#PortfolioOptimiser.ERM","page":"Risk Measures","title":"PortfolioOptimiser.ERM","text":"ERM(x::AbstractVector, z::Real = 1.0, α::Real = 0.05)\n\nCompute the Entropic Risk Measure.\n\nmathrmERM(bmX z alpha) = z ln left(dfracM_bmXleft(z^-1right)alpha right)\n\nwhere M_bmXleft(z^-1right) is the moment generating function of bmX.\n\nInputs\n\nx: vector.\nalpha: significance level, α ∈ (0, 1).\nz: entropic moment, can be obtained from get_z_from_model and get_z after optimising a Portfolio.\n\nERM(x::AbstractVector, solvers::Union{NamedTuple, AbstractDict}, α::Real = 0.05)\n\nCompute the Entropic Risk Measure by minimising the function with respect to z. Used in _EVaR, _EDaR and _EDaR_r.\n\nmathrmERM = begincases\nundersetz t umin  t + z lnleft(dfrac1alpha Tright)\nmathrmst  z geq sumlimits_i=1^T u_i\n (-x_i-t z u_i) in mathcalK_exp  forall  i=1dots T\nendcases\n\nwhere mathcalK_exp is the exponential cone.\n\nInputs\n\nx: vector of portfolio returns.\nsolvers: named tuple or abstract dict containing the a JuMP-compatible solver capable of solving exponential conic problems, this argument can be formulated in various ways depending on the user's needs.\n\nsolvers = Dict(\n    # Key-value pair for the solver, solution acceptance criteria, and solver attributes.\n    :Clarabel => Dict(\n        # Solver we wish to use.\n        :solver => Clarabel.Optimizer, \n        # (Optional) Solution acceptance criteria.\n        :check_sol => (allow_local = true, allow_almost = true), \n        # (Optional) Solver-specific attributes.\n        :params => Dict(\"verbose\" => false)\n    )\n)\n\nThe dictionary contains a key value pair for each solver (plus optional solution acceptance criteria and optional attributes) we want to use.\n\n:solver: defines the solver to use. One can also use JuMP.optimizer_with_attributes to direcly provide a solver with attributes already attached.\n:check_sol: (optional) defines the keyword arguments passed on to JuMP.is_solved_and_feasible for accepting/rejecting solutions.\n:params: (optional) defines solver-specific parameters.\n\nAs long as the same structure is followed, one can use named tuples or even combinations of named tuples and abstract dictionaries.\n\nsolvers = (\n    Clarabel = (\n        # Solver with attributes\n        solver = optimizer_with_attributes(Clarabel.Optimizer, \"verbose\" => false), \n        check_sol = (allow_local = true, allow_almost=true)\n    )\n)\n\nUsers are also able to provide multiple solvers by adding additional key-value pairs to the top-level dictionary/tuple as in the following snippet.\n\nsolvers = Dict(\n    :Clarabel => Dict(\n        :solver => Clarabel.Optimizer, \n        :check_sol => (allow_local = true, allow_almost = true), \n        :params => Dict(\"verbose\" => false)\n    ),\n    :COSMO => Dict(\n        :solver => COSMO.Optimizer,\n        ...\n    ), ...\n)\n\nPortfolioOptimiser will iterate over the solvers until it finds the first one to successfully solve the problem.\n\nα: significance level, α ∈ (0, 1).\n\nIf no valid solution is found then NaN will be returned.\n\n\n\n\n\n","category":"function"},{"location":"RiskMeasures/#Private","page":"Risk Measures","title":"Private","text":"","category":"section"},{"location":"RiskMeasures/","page":"Risk Measures","title":"Risk Measures","text":"Modules = [PortfolioOptimiser]\nPublic = false\nPrivate = true\nPages = [\"RiskMeasures.jl\"]","category":"page"},{"location":"RiskMeasures/#PortfolioOptimiser._ADD-Tuple{AbstractVector}","page":"Risk Measures","title":"PortfolioOptimiser._ADD","text":"_ADD(x::AbstractVector)\n\nCompute the Average Drawdown of uncompounded cumulative returns.\n\nmathrmADD_a(bmX) = dfrac1T sumlimits_j=0^T mathrmDD_a(bmX j)\n\nwhere mathrmDD_a(bmX j) is the Drawdown of uncompounded cumulative returns as defined in _DaR.\n\nInputs\n\nx: vector of portfolio returns.\n\n\n\n\n\n","category":"method"},{"location":"RiskMeasures/#PortfolioOptimiser._ADD_r-Tuple{AbstractVector}","page":"Risk Measures","title":"PortfolioOptimiser._ADD_r","text":"_ADD_r(x::AbstractVector)\n\nCompute the Average Drawdown of compounded cumulative returns.\n\nmathrmADD_r(bmr) = dfrac1T sumlimits_j=0^T mathrmDD_r(bmX j)\n\nwhere mathrmDD_a(bmX j) is the Drawdown of compounded cumulative returns as defined in _DaR_r.\n\nInputs\n\nx: vector of portfolio returns.\n\n\n\n\n\n","category":"method"},{"location":"RiskMeasures/#PortfolioOptimiser._CDaR","page":"Risk Measures","title":"PortfolioOptimiser._CDaR","text":"_CDaR(x::AbstractVector, alpha::Real = 0.05)\n\nCompute the Conditional Drawdown at Risk of uncompounded cumulative returns.\n\nmathrmCDaR_a(bmX alpha) = mathrmDaR_a(bmX alpha) + dfrac1alpha T sumlimits_j=0^T maxleftmathrmDD_a(bmX j) - mathrmDaR_a(bmX alpha) 0 right \n\nwhere mathrmDD_a(bmX j) is the Drawdown of uncompounded cumulative returns as defined in _DaR, and mathrmDaR_a(bmX alpha) the Drawdown at Risk of uncompounded cumulative returns as defined in _DaR.\n\nInputs\n\nx: vector of portfolio returns.\nalpha: significance level, α ∈ (0, 1).\n\n\n\n\n\n","category":"function"},{"location":"RiskMeasures/#PortfolioOptimiser._CDaR_r","page":"Risk Measures","title":"PortfolioOptimiser._CDaR_r","text":"_CDaR_r(x::AbstractVector, alpha::Real = 0.05)\n\nCompute the Conditional Drawdown at Risk of compounded cumulative returns.\n\nmathrmCDaR_r(bmX alpha) = mathrmDaR_r(bmX alpha) + dfrac1alpha T sumlimits_j=0^T maxleftmathrmDD_r(bmX j) - mathrmDaR_r(bmX alpha) 0 right \n\nwhere mathrmDD_r(bmX j) is the Drawdown of compounded cumulative returns as defined in _DaR_r, and mathrmDaR_r(bmX alpha) the Drawdown at Risk of compounded cumulative returns as defined in _DaR_r.\n\nInputs\n\nx: vector of portfolio returns.\nalpha: significance level, α ∈ (0, 1).\n\n\n\n\n\n","category":"function"},{"location":"RiskMeasures/#PortfolioOptimiser._CVaR","page":"Risk Measures","title":"PortfolioOptimiser._CVaR","text":"_CVaR(x::AbstractVector, α::Real = 0.05)\n\nCompute the Conditional Value at Risk.\n\nmathrmCVaR(bmX alpha) = mathrmVaR(bmX alpha) - dfrac1alpha T sumlimits_t=1^T minleft( X_t + mathrmVaR(bmX alpha) 0right)\n\nwhere mathrmVaR(bmX alpha) is the value at risk as defined in _VaR.\n\nInputs\n\nx: vector of portfolio returns.\nα: significance level, α ∈ (0, 1).\n\nwarning: Warning\nIn-place sorts the input vector.\n\n\n\n\n\n","category":"function"},{"location":"RiskMeasures/#PortfolioOptimiser._DVar-Tuple{AbstractVector}","page":"Risk Measures","title":"PortfolioOptimiser._DVar","text":"_DVar(x::AbstractVector)\n\nCompute the Brownian distance variance.\n\nbeginalign*\nmathrmdVar(bmX) = mathrmdCov(bmX bmX) =  dfrac1T^2 sumlimits_i=1^Tsumlimits_j=1^T A_ij^2\nmathrmdCov(bmX bmY) = dfrac1T^2 sumlimits_i=1^T sumlimits_j=1^T A_ij B_ij\nA_ij = a_ij - bara_i - bara_j + bara_\nB_ij = b_ij - barb_i - barb_j + barb_\na_ij = lVert X_i - X_j rVert_2 quad forall i j = 1 ldots  T\nb_ij = lVert Y_i - Y_j rVert_2 quad forall i j = 1 ldots  T\nendalign*\n\nwhere:\n\nbmX and bmY are random variables, they are equal in this case as they are the portfolio returns.\na_ij and b_ij are entries of a distance matrix where i and j are points in time. Each entry is defined as the Euclidean distance lVert  rVert_2 between the value of the random variable at time i and its value at time j.\nbara_i and barb_i are the i-th row means of their respective matrices.\nbara_j and barb_j are the j-th column means of their respective matrices.\nbara_ and barb_ are the grand means of their respective matrices.\nA_ij and B_ij are the doubly centered distances.\n\n\n\n\n\n","category":"method"},{"location":"RiskMeasures/#PortfolioOptimiser._DaR","page":"Risk Measures","title":"PortfolioOptimiser._DaR","text":"_DaR(x::AbstractArray, alpha::Real = 0.05)\n\nCompute the Drawdown at Risk of uncompounded cumulative returns.\n\nbeginalign*\nmathrmDaR_a(bmX alpha) = undersetj in (0 T)max left mathrmDD_a(bmX j) in mathbbR  F_mathrmDDleft(mathrmDD_a(bmX j)right)  1 - alpha right\nmathrmDD_a(bmX j) = undersett in (0 j)maxleft( sumlimits_i=0^t x_i right) - sumlimits_i=0^j x_i\nendalign*\n\nInputs\n\nx: vector of portfolio returns.\nalpha: significance level, α ∈ (0, 1).\n\n\n\n\n\n","category":"function"},{"location":"RiskMeasures/#PortfolioOptimiser._DaR_r","page":"Risk Measures","title":"PortfolioOptimiser._DaR_r","text":"_DaR_r(x::AbstractArray; alpha::Real = 0.05)\n\nCompute the Drawdown at Risk of compounded cumulative returns.\n\nbeginalign*\nmathrmDaR_r(bmX alpha) = undersetj in (0 T)max left mathrmDD_r(bmX j) in mathbbR  F_mathrmDDleft(mathrmDD_r(bmX j)right)  1 - alpha right\nmathrmDD_r(bmX j) = undersett in (0 j)maxleft( prodlimits_i=0^t left(1+x_iright) right) - prodlimits_i=0^j left(1+x_iright) \nendalign*\n\nInputs\n\nx: vector of portfolio returns.\nalpha: significance level, α ∈ (0, 1).\n\n\n\n\n\n","category":"function"},{"location":"RiskMeasures/#PortfolioOptimiser._EDaR","page":"Risk Measures","title":"PortfolioOptimiser._EDaR","text":"_EDaR(x::AbstractVector, solvers::AbstractDict; alpha::Real = 0.05)\n\nCompute the Entropic Drawdown at Risk of uncompounded cumulative returns.\n\nbeginalign*\nmathrmEDaR_a(bmXalpha) = undersetz  0inf leftmathrmERM(mathrmDD_a(bmX) z alpha)right\nmathrmDD_a(bmX) = leftj in (0 T)  mathrmDD_a(bmX j) rightendalign*\n\nwhere mathrmERM(bmX z alpha) is the entropic risk measure as defined in ERM and mathrmDD_a(bmX j) the drawdown of uncompounded cumulative returns as defined in _DaR.\n\nInputs\n\nx: vector of portfolio returns.\nalpha: significance level, α ∈ (0, 1).\n\n\n\n\n\n","category":"function"},{"location":"RiskMeasures/#PortfolioOptimiser._EDaR_r","page":"Risk Measures","title":"PortfolioOptimiser._EDaR_r","text":"_EDaR_r(x::AbstractVector, solvers::AbstractDict; alpha::Real = 0.05)\n\nCompute the Entropic Drawdown at Risk of compounded cumulative returns.\n\nbeginalign*\nmathrmEDaR_r(bmXalpha) = undersetz  0inf leftmathrmERM(mathrmDD_r(bmX) z alpha)right\nmathrmDD_r(bmX) = leftj in (0 T)  mathrmDD_r(bmX j) right\nendalign*\n\nwhere mathrmERM(bmX z alpha) is the entropic risk measure as defined in ERM and mathrmDD_r(bmX j) the drawdown of compounded cumulative returns as defined in _DaR_r.\n\nInputs\n\nx: vector of portfolio returns.\nalpha: significance level, α ∈ (0, 1).\nκ: relativistic deformation parameter.\n\n\n\n\n\n","category":"function"},{"location":"RiskMeasures/#PortfolioOptimiser._EVaR","page":"Risk Measures","title":"PortfolioOptimiser._EVaR","text":"_EVaR(x::AbstractVector, solvers::AbstractDict, alpha::Real = 0.05)\n\nCompute the Entropic Value at Risk.\n\nmathrmEVaR(bmXalpha) = undersetz  0inf leftmathrmERM(bmX z alpha)right\n\nwhere mathrmERM(bmX z alpha) is the entropic risk measure as defined in ERM.\n\nInputs\n\nx: vector of portfolio returns.\nalpha: significance level, α ∈ (0, 1).\n\n\n\n\n\n","category":"function"},{"location":"RiskMeasures/#PortfolioOptimiser._FLPM","page":"Risk Measures","title":"PortfolioOptimiser._FLPM","text":"_FLPM(x::AbstractVector, r::Real = 0.0)\n\nCompute the First Lower Partial Moment (Omega ratio).\n\nmathrmFLPM(bmX r) = dfrac1T  sumlimits_t=1^Tmaxleft(r - bmX_t 0right)\n\nInputs\n\nx: vector of portfolio returns.\nr: minimum return target.\n\n\n\n\n\n","category":"function"},{"location":"RiskMeasures/#PortfolioOptimiser._GMD-Tuple{AbstractVector}","page":"Risk Measures","title":"PortfolioOptimiser._GMD","text":"_GMD(x::AbstractVector)\n\nCompute the Gini Mean Difference.\n\nInputs\n\nx: vector of portfolio returns.\n\n\n\n\n\n","category":"method"},{"location":"RiskMeasures/#PortfolioOptimiser._Kurt","page":"Risk Measures","title":"PortfolioOptimiser._Kurt","text":"_Kurt(x::AbstractVector)\n\nCompute the square root kurtosis.\n\nmathrmKurt(bmX) = leftdfrac1T sumlimits_t=1^T left( X_t - mathbbE(bmX) right)^4 right^12\n\nInputs\n\nx: vector of portfolio returns.\n\n\n\n\n\n","category":"function"},{"location":"RiskMeasures/#PortfolioOptimiser._MAD","page":"Risk Measures","title":"PortfolioOptimiser._MAD","text":"_MAD(x::AbstractVector, w::Union{AbstractWeights, Nothing} = nothing)\n\nCompute the Mean Absolute Deviation.\n\nmathrmMAD(bmX) = dfrac1T sumlimits_t=1^T leftlvert X_t - mathbbE(bmX) rightrvert\n\nInputs\n\nx: vector of portfolio returns.\nw: optional vector of weights for computing the mean.\n\n\n\n\n\n","category":"function"},{"location":"RiskMeasures/#PortfolioOptimiser._MDD-Tuple{AbstractVector}","page":"Risk Measures","title":"PortfolioOptimiser._MDD","text":"_MDD(x::AbstractVector)\n\nCompute the Maximum Drawdown of uncompounded cumulative returns.\n\nmathrmMDD_a(bmX) = undersetj in (0 T)max mathrmDD_a(bmX j)\nwhere mathrmDD_a(bmX j) is the Drawdown of uncompounded cumulative returns as defined in _DaR(ref)\n Inputs\n- x vector of portfolio returns\n\n\n\n\n\n","category":"method"},{"location":"RiskMeasures/#PortfolioOptimiser._MDD_r-Tuple{AbstractVector}","page":"Risk Measures","title":"PortfolioOptimiser._MDD_r","text":"_MDD_r(x::AbstractVector)\n\nCompute the Maximum Drawdown of compounded cumulative returns.\n\nmathrmMDD_r(bmX) = undersetj in (0 T)max mathrmDD_r(bmX j)\nwhere mathrmDD_a(bmX j) is the Drawdown of compounded cumulative returns as defined in _DaR_r(ref)\n Inputs\n- x vector of portfolio returns\n\n\n\n\n\n","category":"method"},{"location":"RiskMeasures/#PortfolioOptimiser._OWA-Tuple{AbstractVector, AbstractVector}","page":"Risk Measures","title":"PortfolioOptimiser._OWA","text":"_OWA(x::AbstractVector, w::AbstractVector)\n\nCompute the Ordered Weight Array risk measure.\n\nInputs\n\nw: vector of asset weights.\nx: vector of portfolio returns.\n\n\n\n\n\n","category":"method"},{"location":"RiskMeasures/#PortfolioOptimiser._RCVaR-Tuple{AbstractVector}","page":"Risk Measures","title":"PortfolioOptimiser._RCVaR","text":"_RCVaR(x::AbstractVector; alpha::Real = 0.05, beta::Real = alpha)\n\nCompute the _CVaR Range.\n\nInputs\n\nx: vector of portfolio returns.\nalpha: significance level of _CVaR losses, α  (0 1).\nbeta: significance level of _CVaR gains, beta in (0, 1).\n\nwarning: Warning\nIn-place sorts the input vector.\n\n\n\n\n\n","category":"method"},{"location":"RiskMeasures/#PortfolioOptimiser._RDaR","page":"Risk Measures","title":"PortfolioOptimiser._RDaR","text":"_RDaR(x::AbstractVector, solvers::AbstractDict; alpha::Real = 0.05, kappa::Real = 0.3)\n\nCompute the Relativistic Drawdown at Risk of uncompounded cumulative returns.\n\nmathrmRDaR_a(bmX alpha kappa) = mathrmRRM(mathrmDD_a(bmX) alpha kappa)\nwhere mathrmRRM(mathrmDD_a(bmX) alpha kappa) is the relativistic risk measure as defined in RRM(ref) and mathrmDD_a(bmX) the drawdown of uncompounded cumulative returns as defined in _DaR(ref)\n Inputs\n- x vector of portfolio returns\n- alpha significance level α  (0 1)\n- κ relativistic deformation parameter\n\n\n\n\n\n","category":"function"},{"location":"RiskMeasures/#PortfolioOptimiser._RDaR_r","page":"Risk Measures","title":"PortfolioOptimiser._RDaR_r","text":"_RDaR_r(x::AbstractVector, solvers::AbstractDict; alpha::Real = 0.05, kappa::Real = 0.3)\n\nCompute the Relativistic Drawdown at Risk of compounded cumulative returns.\n\nmathrmRDaR_r(bmX alpha kappa) = mathrmRRM(mathrmDD_r(bmX) alpha kappa)\nwhere mathrmRRM(mathrmDD_r(bmX) alpha kappa) is the Relativistic Risk Measure as defined in RRM(ref) where the returns vector and mathrmDD_r(bmX) the drawdown of compounded cumulative returns as defined in _DaR_r(ref)\n Inputs\n- x vector of portfolio returns\n- alpha significance level α  (0 1)\n- κ relativistic deformation parameter\n\n\n\n\n\n","category":"function"},{"location":"RiskMeasures/#PortfolioOptimiser._RG-Tuple{AbstractVector}","page":"Risk Measures","title":"PortfolioOptimiser._RG","text":"_RG(x::AbstractVector)\n\nCompute the Range.\n\nInputs\n\nx: vector of portfolio returns.\n\n\n\n\n\n","category":"method"},{"location":"RiskMeasures/#PortfolioOptimiser._RTG-Tuple{AbstractVector}","page":"Risk Measures","title":"PortfolioOptimiser._RTG","text":"_RTG(x::AbstractVector; alpha_i::Real = 0.0001, alpha::Real = 0.05, a_sim::Real = 100,\n     beta_i::Real = alpha_i, beta::Real = alpha, b_sim::Integer = a_sim)\n\nCompute the Tail Gini Range.\n\nInputs\n\nx: vector of portfolio returns.\nalpha_i: start value of the significance level of CVaR losses, `0 <alphai < alpha < 1`.\nalpha: end value of the significance level of _CVaR losses, α  (0 1).\na_sim: number of CVaRs to approximate the Tail Gini losses, a_sim > 0.\nbeta_i: start value of the significance level of CVaR gains, `0 < betai < beta < 1`.\nbeta: end value of the significance level of _CVaR gains, beta in (0, 1).\nb_sim: number of CVaRs to approximate the Tail Gini gains, b_sim > 0.\n\nwarning: Warning\nIn-place sorts the input vector.\n\n\n\n\n\n","category":"method"},{"location":"RiskMeasures/#PortfolioOptimiser._RVaR","page":"Risk Measures","title":"PortfolioOptimiser._RVaR","text":"_RVaR(x::AbstractVector, solvers::AbstractDict, alpha::Real = 0.05, κ::Real = 0.3)\n\nCompute the Relativistic Value at Risk.\n\nmathrmRVaR(bmX alpha kappa) = mathrmRRM(bmX alpha kappa)\nwhere mathrmRRM(bmX alpha kappa) is the Relativistic Risk Measure as defined in RRM(ref)\n Inputs\n- x vector of portfolio returns\n- alpha significance level α  (0 1)\n- κ relativistic deformation parameter\n\n\n\n\n\n","category":"function"},{"location":"RiskMeasures/#PortfolioOptimiser._SD-Tuple{AbstractVector, AbstractMatrix}","page":"Risk Measures","title":"PortfolioOptimiser._SD","text":"_SD(w::AbstractVector, Σ::AbstractMatrix)\n\nCompute the Standard Deviation. Square root of _Variance.\n\nmathrmSD(bmw mathbfSigma) = leftbmw^intercal  mathbfSigma  bmwright^12\n\nInputs\n\nw: vector of asset weights.\nΣ: covariance matrix of asset returns.\n\n\n\n\n\n","category":"method"},{"location":"RiskMeasures/#PortfolioOptimiser._SKurt","page":"Risk Measures","title":"PortfolioOptimiser._SKurt","text":"_SKurt(x::AbstractVector)\n\nCompute the square root semi-kurtosis.\n\nmathrmSKurt(bmX) = leftdfrac1T sumlimits_t=1^T minleft( X_t - mathbbE(bmX) 0 right)^4 right^12\n\nInputs\n\nx: vector of portfolio returns.\n\n\n\n\n\n","category":"function"},{"location":"RiskMeasures/#PortfolioOptimiser._SLPM","page":"Risk Measures","title":"PortfolioOptimiser._SLPM","text":"_SLPM(x::AbstractVector, r::Real = 0.0)\n\nCompute the Second Lower Partial Moment (Sortino Ratio).\n\nmathrmSLPM(bmX r) = leftdfrac1T-1 sumlimits_t=1^Tmaxleft(r - bmX_t 0right)^2right^12\n\nInputs\n\nx: vector of portfolio returns.\nr: minimum return target.\n\n\n\n\n\n","category":"function"},{"location":"RiskMeasures/#PortfolioOptimiser._SSD","page":"Risk Measures","title":"PortfolioOptimiser._SSD","text":"_SSD(x::AbstractVector, r::Real = 0.0, w::Union{AbstractWeights, Nothing} = nothing)\n\nCompute the mean Semi-Standard Deviation.\n\nmathrmSSD(bmX) = leftdfrac1T-1 sumlimits_t=1^Tminleft(bmX_t - mathbbE(bmX) rright)^2right^12\n\nInputs\n\nx: vector of portfolio returns.\nr: minimum return target.\nw: optional vector of weights for computing the mean.\n\n\n\n\n\n","category":"function"},{"location":"RiskMeasures/#PortfolioOptimiser._Skew-Tuple{AbstractVector, AbstractArray}","page":"Risk Measures","title":"PortfolioOptimiser._Skew","text":"_Skew(w::AbstractVector, V::AbstractArray)\n\n\n\n\n\n","category":"method"},{"location":"RiskMeasures/#PortfolioOptimiser._TG-Tuple{AbstractVector}","page":"Risk Measures","title":"PortfolioOptimiser._TG","text":"_TG(x::AbstractVector; alpha_i::Real = 0.0001, alpha::Real = 0.05, a_sim::Int = 100)\n\nCompute the Tail Gini.\n\nInputs\n\nx: vector of portfolio returns.\nalpha_i: start value of the significance level of CVaR losses, `0 <alphai < alpha < 1`.\nalpha: end value of the significance level of _CVaR losses, α  (0 1).\na_sim: number of CVaRs to approximate the Tail Gini losses, a_sim > 0.\n\nwarning: Warning\nIn-place sorts the input vector.\n\n\n\n\n\n","category":"method"},{"location":"RiskMeasures/#PortfolioOptimiser._UCI-Tuple{AbstractVector}","page":"Risk Measures","title":"PortfolioOptimiser._UCI","text":"_UCI(x::AbstractVector)\n\nCompute the Ulcer Index of uncompounded cumulative returns.\n\nmathrmUCI_a(bmX) = leftdfrac1T sumlimits_j=0^T mathrmDD_a(bmX j)^2right^12\nwhere mathrmDD_a(bmX j) is the Drawdown of uncompounded cumulative returns as defined in _DaR(ref)\n Inputs\n- x vector of portfolio returns\n\n\n\n\n\n","category":"method"},{"location":"RiskMeasures/#PortfolioOptimiser._UCI_r-Tuple{AbstractVector}","page":"Risk Measures","title":"PortfolioOptimiser._UCI_r","text":"_UCI_r(x::AbstractVector)\n\nCompute the Ulcer Index of compounded cumulative returns.\n\nmathrmUCI_r(bmX) = leftdfrac1T sumlimits_j=0^T mathrmDD_r(bmX j)^2right^12\nwhere mathrmDD_r(bmX j) is the Drawdown of compounded cumulative returns as defined in _DaR_r(ref)\n Inputs\n- x vector of portfolio returns\n\n\n\n\n\n","category":"method"},{"location":"RiskMeasures/#PortfolioOptimiser._VaR","page":"Risk Measures","title":"PortfolioOptimiser._VaR","text":"_VaR(x::AbstractVector, α::Real = 0.05)\n\nCompute the Value at Risk, used in _CVaR.\n\nmathrmVaR(bmX alpha) = -undersett in (0 T)inf left X_t in mathbbR  F_bmX(X_t)  alpha right\n\nInputs\n\nx: vector of portfolio returns.\nα: significance level, α ∈ (0, 1).\n\nwarning: Warning\nIn-place sorts the input vector.\n\n\n\n\n\n","category":"function"},{"location":"RiskMeasures/#PortfolioOptimiser._Variance-Tuple{AbstractVector, AbstractMatrix}","page":"Risk Measures","title":"PortfolioOptimiser._Variance","text":"_Variance(w::AbstractVector, Σ::AbstractMatrix)\n\nCompute the Variance. Square of [`SD`](@ref).\n\nmathrmVariance(bmw mathbfSigma) = bmw^intercal  mathbfSigma bmw\n\nInputs\n\nw: vector of asset weights.\nΣ: covariance matrix of asset returns.\n\n\n\n\n\n","category":"method"},{"location":"RiskMeasures/#PortfolioOptimiser._WR-Tuple{AbstractVector}","page":"Risk Measures","title":"PortfolioOptimiser._WR","text":"_WR(x::AbstractVector)\n\nCompute the Worst Realisation or Worst Case Scenario.\n\nmathrmWR(bmX) = -min(bmX)\n\nInputs\n\nx: vector of portfolio returns.\n\n\n\n\n\n","category":"method"},{"location":"PortfolioOptim/#Portfolio-Optimisation","page":"Portfolio Optimisation","title":"Portfolio Optimisation","text":"","category":"section"},{"location":"PortfolioOptim/#Public","page":"Portfolio Optimisation","title":"Public","text":"","category":"section"},{"location":"PortfolioOptim/","page":"Portfolio Optimisation","title":"Portfolio Optimisation","text":"Modules = [PortfolioOptimiser]\nPublic = true\nPrivate = false\nPages = [\"PortfolioOptim.jl\"]","category":"page"},{"location":"PortfolioOptim/#PortfolioOptimiser.get_z-Tuple{Portfolio, Union{PortfolioOptimiser.TradRiskMeasure, AbstractVector}, Any}","page":"Portfolio Optimisation","title":"PortfolioOptimiser.get_z","text":"get_z\n\n\n\n\n\n","category":"method"},{"location":"PortfolioOptim/#PortfolioOptimiser.get_z_from_model-Tuple{JuMP.Model, EVaR, Any}","page":"Portfolio Optimisation","title":"PortfolioOptimiser.get_z_from_model","text":"get_z_from_model\n\n\n\n\n\n","category":"method"},{"location":"PortfolioOptim/#Private","page":"Portfolio Optimisation","title":"Private","text":"","category":"section"},{"location":"PortfolioOptim/","page":"Portfolio Optimisation","title":"Portfolio Optimisation","text":"Modules = [PortfolioOptimiser]\nPublic = false\nPrivate = true\nPages = [\"PortfolioOptim.jl\"]","category":"page"},{"location":"PortfolioTypes/#Portfolio-Optimisation","page":"Portfolio Types","title":"Portfolio Optimisation","text":"","category":"section"},{"location":"PortfolioTypes/#Public","page":"Portfolio Types","title":"Public","text":"","category":"section"},{"location":"PortfolioTypes/","page":"Portfolio Types","title":"Portfolio Types","text":"Modules = [PortfolioOptimiser]\nPublic = true\nPrivate = false\nPages = [\"PortfolioTypes.jl\"]","category":"page"},{"location":"PortfolioTypes/#PortfolioOptimiser.Portfolio","page":"Portfolio Types","title":"PortfolioOptimiser.Portfolio","text":"mutable struct Portfolio{ast, dat, r, s, us, ul, nal, nau, naus, tfa, tfdat, tretf, l, lo,\n                         mnak, mnaks, rb, to, kte, blbw, ami, bvi, rbv, frbv, nm, amc, bvc,\n                         ler, tmu, tcov, tkurt, tskurt, tl2, ts2, tskew, tv, tsskew, tsv,\n                         tmuf, tcovf, trfm, tmufm, tcovfm, tmubl, tcovbl, tmublf, tcovblf,\n                         tcovl, tcovu, tcovmu, tcovs, tdmu, tkmu, tks, topt, tz, tlim,\n                         tfront, tsolv, tf, tmod, tlp, taopt, talo, tasolv, taf, tamod} <:\n               AbstractPortfolio\n    assets::ast\n    timestamps::dat\n    returns::r\n    short::s\n    short_u::us\n    long_u::ul\n    num_assets_l::nal\n    num_assets_u::nau\n    num_assets_u_scale::naus\n    f_assets::tfa\n    f_timestamps::tfdat\n    f_returns::tretf\n    loadings::l\n    loadings_opt::lo\n    max_num_assets_kurt::mnak\n    max_num_assets_kurt_scale::mnaks\n    rebalance::rb\n    turnover::to\n    tracking_err::kte\n    bl_bench_weights::blbw\n    a_mtx_ineq::ami\n    b_vec_ineq::bvi\n    risk_budget::rbv\n    f_risk_budget::frbv\n    network_method::nm\n    a_vec_cent::amc\n    b_cent::bvc\n    mu_l::ler\n    mu::tmu\n    cov::tcov\n    kurt::tkurt\n    skurt::tskurt\n    L_2::tl2\n    S_2::ts2\n    skew::tskew\n    V::tv\n    sskew::tsskew\n    SV::tsv\n    f_mu::tmuf\n    f_cov::tcovf\n    fm_returns::trfm\n    fm_mu::tmufm\n    fm_cov::tcovfm\n    bl_mu::tmubl\n    bl_cov::tcovbl\n    blfm_mu::tmublf\n    blfm_cov::tcovblf\n    cov_l::tcovl\n    cov_u::tcovu\n    cov_mu::tcovmu\n    cov_sigma::tcovs\n    d_mu::tdmu\n    k_mu::tkmu\n    k_sigma::tks\n    optimal::topt\n    z::tz\n    limits::tlim\n    frontier::tfront\n    solvers::tsolv\n    fail::tf\n    model::tmod\n    latest_prices::tlp\n    alloc_optimal::taopt\n    alloc_leftover::talo\n    alloc_solvers::tasolv\n    alloc_fail::taf\n    alloc_model::tamod\nend\n\n\n\n\n\n","category":"type"},{"location":"PortfolioTypes/#Private","page":"Portfolio Types","title":"Private","text":"","category":"section"},{"location":"PortfolioTypes/","page":"Portfolio Types","title":"Portfolio Types","text":"Modules = [PortfolioOptimiser]\nPublic = false\nPrivate = true\nPages = [\"PortfolioTypes.jl\"]","category":"page"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = PortfolioOptimiser","category":"page"},{"location":"#PortfolioOptimiser","page":"Home","title":"PortfolioOptimiser","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for PortfolioOptimiser.","category":"page"}]
}