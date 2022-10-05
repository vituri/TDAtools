library(simplextree)
library(vituripackage)

st <- simplex_tree()
x = list(a = 1, b = 1:2, c = 3)
st %>% insert(x)
plot(st)
st$as_XPtr()
plot(st)
st$as_edge_list()
plot(st)

nv = nerve(st = st, cover = list(1:2, 1:3, 1), k = 3)
nv %>% plot()

nv$as_edge_list()

Mapper:::build_0_skeleton()

d = dist(testdata.noisy_circle(n = 50))
x = rips(d, eps = 0.3, dim = 1L, filtered = TRUE)
