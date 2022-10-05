require(visNetwork, quietly = TRUE)
library(visNetwork)
# minimal example
nodes <- data.frame(id = 1:3)
edges <- data.frame(from = c(1,2), to = c(1,3))
visNetwork(nodes, edges, width = "100%")

library(shiny)

ui <- fluidPage(
  visNetworkOutput('plot')
  ,actionButton('botao', 'botao')
)

server <- function(input, output, session) {
  output$plot = renderVisNetwork({
    require(visNetwork, quietly = TRUE)
    # minimal example
    nodes <- data.frame(id = 1:3)
    edges <- data.frame(from = c(1,2), to = c(1,3))

    g = visNetwork(nodes, edges, width = "100%")
  })

  observe({

    invalidateLater(1000)

    visNetworkProxy('plot') %>%
      visGetSelectedNodes(input = paste0("abcselectedNodes"))
  })

  observe({
    browser()

    input$abcselectedNodes
  }) %>%
    bindEvent(input$botao)


}

shinyApp(ui, server)
