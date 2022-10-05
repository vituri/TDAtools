filter_functions = list(
  excentricity_filter = function(D, p){
    if (p != 0){
      #    apply(X = M, MARGIN = 1, FUN = function(x) (sum(x^p)/nrow(M))^(1/p))
      rowMeans(D^p)^(1/p)
    } else {
      apply(X = D, MARGIN = 1, FUN = max)
    }

  }
)
