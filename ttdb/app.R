#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)

#Database connection 

library(DBI)
library(RSQLite)

# Veritabanı bağlantısını oluştur
con <- dbConnect(RSQLite::SQLite(), "my_database.db")


# Define UI for application that draws a histogram
ui <- fluidPage(
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  #Creating table query 
  create_table_query <- "
  CREATE TABLE fossils (
    id INTEGER PRIMARY KEY,
    species TEXT,
    age INTEGER,
    location TEXT
  )
"
}
  # Working query 
  dbExecute(con, create_table_query)


# Run the application 
shinyApp(ui = ui, server = server)
