using Test, PortfolioOptimiser, DataFrames, TimeSeries, CSV, Dates

@testset "Asset constraints" begin
    A = TimeArray(CSV.File("./test/assets/stock_prices.csv"), timestamp = :date)
    Y = percentchange(A)
    returns = dropmissing!(DataFrame(Y))

    asset_classes = Dict(
        "Assets" => ["FB", "GOOGL", "NTFX", "BAC", "WFC", "TLT", "SHV"],
        "Class 1" => [
            "Equity",
            "Equity",
            "Equity",
            "Equity",
            "Equity",
            "Fixed Income",
            "Fixed Income",
        ],
        "Class 2" => [
            "Technology",
            "Technology",
            "Technology",
            "Financial",
            "Financial",
            "Treasury",
            "Treasury",
        ],
    )

    constraints = Dict(
        "Enabled" => [true, true, true, true, true, true, true],
        "Type" => [
            "Classes",
            "All Classes",
            "Assets",
            "Assets",
            "Classes",
            "All Assets",
            "Each asset in a class",
        ],
        "Set" => ["Class 1", "Class 1", "", "", "Class 2", "", "Class 1"],
        "Position" =>
            ["Equity", "Fixed Income", "BAC", "WFC", "Financial", "", "Equity"],
        "Sign" => ["<=", "<=", "<=", "<=", ">=", ">=", ">="],
        "Weight" => [0.6, 0.5, 0.1, "", "", 0.02, ""],
        "Type Relative" => ["", "", "", "Assets", "Classes", "", "Assets"],
        "Relative Set" => ["", "", "", "", "Class 1", "", ""],
        "Relative" => ["", "", "", "FB", "Fixed Income", "", "TLT"],
        "Factor" => ["", "", "", 1.2, 0.5, "", 0.4],
    )

    constraints = DataFrame(constraints)
    asset_classes = DataFrame(asset_classes)
    sort!(asset_classes, "Assets")

    A, B = asset_constraints(constraints, asset_classes)

    asset_classes = Dict(
        "Assets" => ["FB", "GOOGL", "NTFX", "BAC", "WFC", "TLT", "SHV"],
        "Class 1" => [
            "Equity",
            "Equity",
            "Equity",
            "Equity",
            "Equity",
            "Fixed Income",
            "Fixed Income",
        ],
        "Class 2" => [
            "Technology",
            "Technology",
            "Technology",
            "Financial",
            "Financial",
            "Treasury",
            "Treasury",
        ],
    )

    constraints = Dict(
        "Enabled" => [true, true, true, true, true, true, true],
        "Type" => [
            "Classes",
            "All Classes",
            "Assets",
            "Assets",
            "Classes",
            "All Assets",
            "Each asset in a class",
        ],
        "Set" => ["Class 1", "Class 1", "", "", "Class 2", "", "Class 1"],
        "Position" =>
            ["Equity", "Fixed Income", "BAC", "WFC", "Financial", "", "Equity"],
        "Sign" => ["<=", "<=", "<=", "<=", ">=", ">=", ">="],
        "Weight" => [0.6, 0.5, 0.1, "", "", 0.02, ""],
        "Type Relative" => ["", "", "", "Assets", "Classes", "", "Assets"],
        "Relative Set" => ["", "", "", "", "Class 1", "", ""],
        "Relative" => ["", "", "", "FB", "Fixed Income", "", "TLT"],
        "Factor" => ["", "", "", 1.2, 0.5, "", 0.4],
    )

    constraints = DataFrame(constraints)
    asset_classes = DataFrame(asset_classes)
    sort!(asset_classes, "Assets")

    A, B = asset_constraints(constraints, asset_classes)

    At = transpose(
        hcat(
            [
                [-1.0, -1.0, -1.0, -1.0, 0.0, 0.0, -1.0],
                [-1.0, -1.0, -1.0, -1.0, 0.0, 0.0, -1.0],
                [0.0, 0.0, 0.0, 0.0, -1.0, -1.0, 0.0],
                [-1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
                [-0.0, 1.2, -0.0, -0.0, -0.0, -0.0, -1.0],
                [1.0, 0.0, 0.0, 0.0, -0.5, -0.5, 1.0],
                [1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
                [0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0],
                [0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0],
                [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0],
                [0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0],
                [0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0],
                [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0],
                [1.0, 0.0, 0.0, 0.0, 0.0, -0.4, 0.0],
                [0.0, 1.0, 0.0, 0.0, 0.0, -0.4, 0.0],
                [0.0, 0.0, 1.0, 0.0, 0.0, -0.4, 0.0],
                [0.0, 0.0, 0.0, 1.0, 0.0, -0.4, 0.0],
                [0.0, 0.0, 0.0, 0.0, 0.0, -0.4, 1.0],
            ]...,
        ),
    )

    Bt = vcat(
        [
            [-0.6],
            [-0.5],
            [-0.5],
            [-0.1],
            [0.0],
            [0.0],
            [0.02],
            [0.02],
            [0.02],
            [0.02],
            [0.02],
            [0.02],
            [0.02],
            [0.0],
            [0.0],
            [0.0],
            [0.0],
            [0.0],
        ]...,
    )

    @test At == A
    @test Bt == B
end

@testset "Factor constraints" begin
    loadings = Dict(
        "const" => [0.0004, 0.0002, 0.0000, 0.0006, 0.0001, 0.0003, -0.0003],
        "MTUM" => [0.1916, 1.0061, 0.8695, 1.9996, 0.0000, 0.0000, 0.0000],
        "QUAL" => [0.0000, 2.0129, 1.4301, 0.0000, 0.0000, 0.0000, 0.0000],
        "SIZE" => [0.0000, 0.0000, 0.0000, 0.4717, 0.0000, -0.1857, 0.0000],
        "USMV" => [-0.7838, -1.6439, -1.0176, -1.4407, 0.0055, 0.5781, 0.0000],
        "VLUE" => [1.4772, -0.7590, -0.4090, 0.0000, -0.0054, -0.4844, 0.9435],
    )

    loadings = DataFrame(loadings)

    constraints = Dict(
        "Enabled" => [true, true, true, true],
        "Factor" => ["MTUM", "USMV", "VLUE", "const"],
        "Sign" => ["<=", "<=", ">=", ">="],
        "Value" => [0.9, -1.2, 0.3, -0.1],
        "Relative Factor" => ["USMV", "", "", "SIZE"],
    )

    constraints = DataFrame(constraints)

    C, D = factor_constraints(constraints, loadings)

    Ct = transpose(
        hcat(
            [
                [
                    -9.7540e-01,
                    -2.6500e+00,
                    -1.8871e+00,
                    -3.4403e+00,
                    5.5000e-03,
                    5.7810e-01,
                    -0.0000e+00,
                ],
                [
                    7.8380e-01,
                    1.6439e+00,
                    1.0176e+00,
                    1.4407e+00,
                    -5.5000e-03,
                    -5.7810e-01,
                    -0.0000e+00,
                ],
                [
                    1.4772e+00,
                    -7.5900e-01,
                    -4.0900e-01,
                    0.0000e+00,
                    -5.4000e-03,
                    -4.8440e-01,
                    9.4350e-01,
                ],
                [
                    4.0000e-04,
                    2.0000e-04,
                    0.0000e+00,
                    -4.7110e-01,
                    1.0000e-04,
                    1.8600e-01,
                    -3.0000e-04,
                ],
            ]...,
        ),
    )

    Dt = vcat([
        [-0.9]
        [1.2]
        [0.3]
        [-0.1]
    ]...)

    @test isapprox(Ct, C)
    @test Dt == D
end