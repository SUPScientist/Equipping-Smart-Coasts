#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(rerddap)
library(xts)
library(dplyr)
library(dygraphs)
library(shinythemes)
library(lubridate)

setwd(getwd())

#Variables you want to read
variables = c('time', 'O2_umol_per_kg', 'pH_total', 'Temp_C', 'Sal_PSS', 'Pressure_dbar', 'Omega_Ar')

#Pull Data from ERDDAP
CAF = rerddap::info(datasetid = "pH-AHL", url="http://erddap.sccoos.org/erddap/")
CAF_Data = tabledap(CAF, fields = variables, url = "http://erddap.sccoos.org/erddap/")

filtered_data <- CAF_Data
filtered_data$Pressure_dbar <- as.numeric(filtered_data$Pressure_dbar)
filtered_data$numtime <- as.numeric(ymd_hms(filtered_data$time))

endDate = as.Date(max(filtered_data$time))
startDate = endDate - 7
minDate = as.Date(min(filtered_data$time))

# Define UI for application that draws a histogram
ui <- fluidPage(

    theme = shinytheme("cerulean"),

    # Application title
    titlePanel("AHL Observations"),

        # Show a plot of the generated distribution
        mainPanel(
            sliderInput(inputId = "Date",
                        label = "Time Interval",
                        width = '100%',
                        min = minDate,
                        max = endDate,
                        value = c(startDate, endDate)),
            dygraphOutput("temp", width = "100%", height = "200px"),
            br(),
            br(),
            dygraphOutput("press", width = "100%", height = "200px"),
            br(),
            br(),
            dygraphOutput("sal", width = "100%", height = "200px"),
            br(),
            br(),
            dygraphOutput("ph", width = "100%", height = "200px"),
            br(),
            br(),
            dygraphOutput("o2", width = "100%", height = "200px"),
            br(),
            br(),
            dygraphOutput("ar", width = "100%", height = "200px")
        )
)


# Define server logic required to draw a histogram
server <- function(input, output) {
    require(dygraphs)

    ahl_data <- filtered_data

    temp_ts = xts(x = ahl_data$Temp_C, order.by =  as_datetime(ahl_data$numtime))
    press_ts = xts(x = ahl_data$Pressure_dbar, order.by = as_datetime(ahl_data$numtime))
    sal_ts = xts(x = ahl_data$Sal_PSS, order.by = as_datetime(ahl_data$numtime))
    ph_ts = xts(x = ahl_data$pH_total, order.by = as_datetime(ahl_data$numtime))
    O2_ts = xts(x = ahl_data$O2_umol_per_kg, order.by = as_datetime(ahl_data$numtime))
    Ar_ts = xts(x = ahl_data$Omega_Ar, order.by = as_datetime(ahl_data$numtime))

    output$temp <- renderDygraph({
        dygraph(temp_ts,
                ylab = "Temp_C",
                group="AHLObs") %>%
        dyRangeSelector(height = 2, dateWindow = c(input$Date[1], input$Date[2]))
    })
    output$press <- renderDygraph({
        dygraph(press_ts,
                ylab = "Pressure",
                group="AHLObs") %>%
            dyRangeSelector(height = 2, dateWindow = c(input$Date[1], input$Date[2]))
    })
    output$sal <- renderDygraph({
            dygraph(sal_ts,
                ylab = "Salinity",
                group="AHLObs") %>%
            dyRangeSelector(height = 2, dateWindow = c(input$Date[1], input$Date[2]))
    })
    output$ph <- renderDygraph({
                dygraph(ph_ts,
                ylab = "pH",
                group="AHLObs") %>%
            dyRangeSelector(height = 2, dateWindow = c(input$Date[1], input$Date[2]))
    })
    output$o2 <- renderDygraph({
            dygraph(O2_ts,
                ylab = "O2",
                group="AHLObs") %>%
            dyRangeSelector(height = 2, dateWindow = c(input$Date[1], input$Date[2]))
    })
    output$ar <- renderDygraph({
            dygraph(Ar_ts,
                ylab = "Omega_Ar",
                group="AHLObs") %>%
            dyRangeSelector(height = 2, dateWindow = c(input$Date[1], input$Date[2]))
    })
}

# Run the application
shinyApp(ui = ui, server = server)
