dados_modelo =
  readRDS('testes/dados_modelo_tudo') %>%
  filter(Evento %in% c('Sonolência N1', 'Sonolência N2')) %>%
  slice_sample(n = 5000)

X = dados_modelo %>% select(where(is.numeric)) %>% select(1:20) %>% as.matrix()

D = dist(X) %>% as.matrix()

excentricity_filter = function(D, p){
  if (p != 0){
    #    apply(X = M, MARGIN = 1, FUN = function(x) (sum(x^p)/nrow(M))^(1/p))
    rowMeans(D^p)^(1/p)
  } else {
    f_x = D[,1]

    for (i in seq_along(f_x)) {
      f_x[i] = max(D[i, ])
    }

    # or apply?
    # apply(X = D, MARGIN = 1, FUN = max)
  }
}

dados_modelo =
  readRDS('testes/dados_modelo_tudo') %>%
  filter(Evento %in% c('Sonolência N1', 'Sonolência N2')) %>%
  slice_sample(n = 5000)

X = dados_modelo %>% select(where(is.numeric)) %>% select(1:20) %>% as.matrix()

D = dist(X) %>% as.matrix()

excentricity_filter = function(D, p){
  if (p != 0){
    #    apply(X = M, MARGIN = 1, FUN = function(x) (sum(x^p)/nrow(M))^(1/p))
    rowMeans(D^p)^(1/p)
  } else {
    f_x = D[,1]

    for (i in seq_along(f_x)) {
      f_x[i] = max(D[i, ])
    }

  }
}

\(x) {
  bench::mark(
    loopao = {f_x = D[,1]

    for (i in seq_along(f_x)) {
      f_x[i] = max(D[i, ])
    }}
    ,applyzao = {
      apply(X = D, MARGIN = 1, FUN = max)
    }
    ,check = FALSE
    ,memory = FALSE
  )
}

\(x) {
  p = 2

  bench::mark(
    forzao = {
      f_x = D[,1]

      for (i in seq_along(f_x)) {
        f_x[i] = (sum(D[i, ]^p))^(1/p)
      }
    }
    ,applyzao = {
      rowMeans(D^p)^(1/p)
    }
    ,check = FALSE
    ,memory = FALSE
  )
}


p = 1
rowMeans(D^p)^(1/p)


