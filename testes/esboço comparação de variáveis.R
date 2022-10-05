x = iris %>% slice_sample(n = 2)
coluna = 'Sepal.Length'
coluna = 'Species'

tudo =
  bind_rows(
    iris %>% mutate(.tipo = 'total')
    ,x %>% mutate(.tipo = 'sample')
  )

tudo$.tipo %<>% factor(levels = c('total', 'sample'))

ggplot(data = tudo, aes(x=Species, fill=.tipo)) +
  geom_histogram(alpha=0.8, stat = 'count', position = 'identity') +
  theme_minimal()

tudo %>%
  select(-.tipo) %>%
  imap(function(x, coluna) {
    if (is.numeric(x)) {
      ggplot(data = tudo, aes(x = x, fill = .tipo)) +
        geom_density(alpha = 0.8) +
        theme_minimal()
    } else {
      ggplot(data = tudo, aes(x = x, fill = .tipo)) +
        geom_histogram(alpha = 0.8, stat = 'count', position = 'identity') +
        theme_minimal()
    }
  })
