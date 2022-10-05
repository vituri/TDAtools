library(shiny)
library(argusui)
library(plotly)
library(GGally)

body =
  argusui::ui.body(

    argusui::ui.box_padrao(
      title = 'Parameters'
      ,flowLayout(
        numericInput(inputId = 'number_intervals', label = 'Number of intervals', value = 10, min = 2, max = 1000, step = 1)

        ,numericInput(inputId = 'percent_overlap', label = '% of overlap', value = 50, min = 1, max = 100, step = 1)
      )

      ,footer = actionButton(inputId = 'apply_parameters', label = 'Apply')
    )

    ,argusui::ui.box_padrao(
      title = 'Mapper'
      ,plotlyOutput(outputId = 'mapper_plot')
    )

    ,argusui::ui.box_padrao(
      title = 'Selected points details'
      ,pickerInput(inputId = 'columns_selected_points_info', label = 'Columns to analyze', choices = NULL, selected = NULL, multiple = TRUE)
      ,plotOutput(outputId = 'selected_points_info')
    )
  )

ui <-
  argusui::ui.tudo(

    header = argusui::ui.header(title = 'Mapper')

    ,sidebar = argusui::ui.sidebar()

    ,body = body
  )

server <- function(input, output, session) {

  rc.data = reactive({
    X
  })

  observe({
    X = rc.data()

    columns = names(X)

    # !!!! cuidado com o 1:3
    updatePickerInput(session = session, inputId = 'columns_selected_points_info', choices = columns, selected = columns[1:3])
  }) %>%
    bindEvent(rc.data())

  rc.data_for_mapper = reactive({

    X = rc.data()

    X %>% select(where(is.numeric)) %>% as.matrix()
  })

  rc.filter_map = reactive({
    X = rc.data()

    X %>% pull(1)
  })

  rc.mapper = reactive({

    req(rc.filter_map())
    req(rc.data_for_mapper())

    # browser()

    m <-
      MapperRef$new()$
      use_data(rc.data_for_mapper())$
      use_filter(filter = rc.filter_map())$
      use_cover(cover = "fixed interval", number_intervals = input$number_intervals, percent_overlap = input$percent_overlap)$
      use_distance_measure(measure = "euclidean")$
      use_clustering_algorithm(cl = "single")$
      construct_pullback()$
      construct_nerve(k = 0L)$
      construct_nerve(k = 1L)

    m
  }) %>%
    bindEvent(input$apply_parameters, ignoreNULL = FALSE, ignoreInit = FALSE)

  rc.mapper_graph = reactive({
    m = rc.mapper()
    req(m)
    G = m %>% format_graph_from_mapper()

    G
  })

  output$mapper_plot = renderPlotly({
    # grafo
    G = rc.mapper_graph()
    req(G)

    browser()

    faixa = cut_interval(V(G)$size, n = 20)
    cores = rainbow(nlevels(faixa))[as.integer(faixa)]
    names(cores) = levels(faixa)[unique(as.integer(faixa))]

    x = cut_number(V(G)$size, n = 10)
    col = rainbow(10)
    names(col) = levels(x)

    p =
      ggnet2(net = G, label = V(G)$name, color.palette = col, color = x, size = V(G)$size, color.legend = 'faixa') %>%
      ggplotly(source = 'mapper_plot') %>%
      config(
        displaylogo = FALSE
        ,modeBarButtonsToRemove = c(
          'sendDataToCloud', 'autoScale2d'
          # ,'resetScale2d'
          ,'toggleSpikelines',
          'hoverClosestCartesian', 'hoverCompareCartesian',
          'zoom2d','pan2d'
          # ,'select2d'
          # ,'lasso2d','zoomIn2d','zoomOut2d'
        ))

    p

  })

  rc.selected_graph_points = reactive({

    G = rc.mapper_graph()
    req(G)

    selected_data = event_data(event = "plotly_selected", source = 'mapper_plot')
    req(selected_data)

    if (length(selected_data) == 0) {
      selected_graph_points = V(G)$name
    } else {
      selected_graph_points =
        selected_data %>%
        slice_max(curveNumber, n = 1) %>%
        pull(pointNumber)
    }

    selected_graph_points

  })

  rc.selected_X_data = reactive({
    selected_graph_points = rc.selected_graph_points()

    selected_X_data =
      extract_X_points_by_vertex(m = rc.mapper(), X = rc.data(), vertices = rc.selected_graph_points())

    selected_X_data

  })

  output$selected_points_info = renderPlot({
    selected_X_data = rc.selected_X_data()
    req(selected_X_data)

    selected_X_data %>%
      select(all_of(input$columns_selected_points_info)) %>%
      ggpairs(mapping = aes(color = selected_X_data$tipo, alpha = 0.5))

  })

  observe({
    rc.selected_graph_points() %>%
      print()
  })

  observe({
    rc.selected_X_data() %>%
      print()
  })

}

shinyApp(ui, server)
