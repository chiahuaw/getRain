

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("金門縣歷史雨量查詢"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      selectInput("years",
                  "年度",
                  choices=(c("2006","2007","2008","2009","2010","2011","2012","2013","2014","2015")),
                  selected="2015"
                  )
    ),

    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("plotyear")
    )
  )
))
