# instala o diacho do pacote
# devtools::install_github(repo = "peekxc/simplextree@6e34926b3e6c7c990226e23ba075e29e9a374365")
# devtools::install_github(repo = "peekxc/Mapper")

library(Mapper)
library(igraph)
library(vituripackage)

n <- 1500
t <- 2*pi*runif(n)
r <- runif(n, min = 2, max = 2.1)
circle = tibble(x = r*cos(t), y = r*sin(t))

X =
  bind_rows(
    circle
    ,tibble(x = runif(500, 1, 4), y = runif(500, -0.1, 0.1))
    ,circle %>% mutate(x = x + 5)
  )

X$tipo = letters[1:3] %>% sample_safe(nrow(X))

f_x <- X$x - min(X$x)

cores = f_x %>% color_vector()

plot(X %>% select(x, y))
plot(X %>% select(x, y), col = cores)

m <-
  MapperRef$new()$
  use_data(X %>% select(x, y) %>% as.matrix())$
  use_filter(filter = f_x)$
  use_cover(cover = "fixed interval", number_intervals = 12L, percent_overlap = 20)$
  use_distance_measure(measure = "euclidean")$
  use_clustering_algorithm(cl = "single")$
  construct_pullback()$
  construct_nerve(k = 0L)$
  construct_nerve(k = 1L)

# grafo
G = m$as_igraph()
plot(G)

l = G %>% igraph::layout_with_fr()
l
plot(G, layout = l)

vertices = 0:2


identical(m$X(), noisy_circle)

points_in_vertex = m$vertices
G = m$as_igraph()
vertices = V(G)
edges = G %>% as_edgelist()

vertex_info =
  points_in_vertex %>%
  purrr::map(function(ids) {

    value = median(noisy_circle[ids, 1])
    size = length(ids)

    list(
      points = ids
      ,value = value
      ,size = size
    )
  })

V(G)$label = NA_character_

size =
  vertex_info %>%
  map_int(pluck('size'))


# reescalou de maneira linear. precisa de mais? log do tamanho? quadrado? raiz?
rescale_function = log
size_rescaled = scales::rescale(rescale_function(size), to = c(4, 20))

color = 'red'

graph_properties = list(
  points_in_vertex = points_in_vertex
  ,size = size
  ,size_rescaled = size_rescaled
  ,color = color
  ,legend = '?'
  ,edges = edges
  ,layout = '?'
)



names(vertex_info) %>%
  iwalk(function(id, i) {
    V(G)[id]$size <<- size_rescaled[i] #vertex_info[[id]]$size
  })



plot(G)


(1:1e6)^2
