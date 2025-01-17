"""
```
abstract type AbstractLoGo end
```

Abstract type for subtyping LoGo covariance and correlation matrix estimators.
"""
abstract type AbstractLoGo end

"""
```
struct NoLoGo <: AbstractLoGo end
```

Leave the matrix as is.
"""
struct NoLoGo <: AbstractLoGo end

"""
```
@kwdef mutable struct LoGo <: AbstractLoGo
    distance::DistMethod = DistMLP()
    similarity::DBHTSimilarity = DBHTMaxDist()
end
```

Compute the LoGo covariance and correlation matrix estimator.

# Parameters

  - `distance`: method for computing the distance (disimilarity) matrix from the correlation matrix if the distance matrix is not provided to [`logo!`](@ref).
  - `similarity`: method for computing the similarity matrix from the correlation and distance matrices. The distance matrix is used to compute sparsity pattern of the inverse of the LoGo covariance and correlation matrices.
"""
mutable struct LoGo <: AbstractLoGo
    distance::DistMethod
    similarity::DBHTSimilarity
end
function LoGo(; distance::DistMethod = DistMLP(),
              similarity::DBHTSimilarity = DBHTMaxDist())
    return LoGo(distance, similarity)
end

export NoLoGo, LoGo
