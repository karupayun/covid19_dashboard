body_plots <- dashboardBody(
  fluidRow(
    fluidRow(
      uiOutput("box_caseEvolution")
    )
  )
)

page_plots <- dashboardPage(
  title   = "Grafos",
  header  = dashboardHeader(disable = TRUE),
  sidebar = dashboardSidebar(disable = TRUE),
  body    = body_plots
)