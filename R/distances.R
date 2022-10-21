#' Distance from a point x to a set X
#' @param x A point.
#' @param X A vector of points.
#' @returns A vector of the same size as x, with the corresponding distance from x to each element of X.
dist_point_to_set = function(x, X){
  # do I need sqrt here?
  # more distances?

  # sqrt(outer(rowSums(x^2), rowSums(y^2), '+') - tcrossprod(x, 2 * y))


  d = colSums((t(X)-x)^2)
}

#' Farthest point sample of a set
#' @param X A dataframe or matrix of points.
#' @param p The amount of points after the procedure.
farthest_points_sample = function(X, p = 1000){
  X = as.matrix(X)
  n = nrow(X)

  # p can be no bigger than n
  p = min(n, p)

  if (n == p) {
    return(seq.int(n))
  }

  ids = rep(0, p)

  # choose the first point
  ids[1] = sample(x = n, size = 1)
  min_dist = dist_point_to_set(x = X[ids[1],], X = X)

  for (i in 2:p) {
    d_i = dist_point_to_set(x = X[ids[i - 1], ], X = X)
    min_dist = pmin(min_dist, d_i)
    ids[i] = which.max(min_dist)

    if (ids[i] == ids[i-1]) break
  }

  if (i < p) {
    ids[i:p] = ids[i]
  }

  return(ids)
}

\(x) {
  X = matrix(rnorm(5000), ncol = 2)
  ids = X %>% farthest_points_sample(1000)

  plot(X)
  points(X[ids, ], col = 'red', pch = 20, cex = 0.8)

  plot(X[ids,])
}
