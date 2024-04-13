#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#
library(shiny)

# Veritabanı bağlantısını oluştur
library(DBI)
library(RSQLite)
con <- dbConnect(RSQLite::SQLite(), "my_database.db")

# Define UI for application
ui <- fluidPage(
  titlePanel("Fosil Veritabanı"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("species", "Fosil Türü:"),
      numericInput("age", "Yaş:", value = NULL),
      textInput("location", "Konum:"),
      actionButton("submit", "Kayıt Ekle")
    ),
    
    mainPanel(
      br(),
      h3("Fosil Kayıtları"),
      tableOutput("fossil_table"),
      br(),
      textInput("search", "Arama:"),
      actionButton("search_button", "Ara"),
      downloadButton("download", "Sonuçları İndir")
    )
  )
)


# Define server logic
server <- function(input, output) {
  
  #Creating table query 
  create_table_query <- "
    CREATE TABLE IF NOT EXISTS fossils (
      id INTEGER PRIMARY KEY,
      species TEXT,
      age INTEGER,
      location TEXT
    )
  "
  
  # Working query 
  dbExecute(con, create_table_query)
  
  # Kayıt ekleme işlevi
  observeEvent(input$submit, {
    species <- input$species
    age <- input$age
    location <- input$location
    
    # Kaydı veritabanına ekle
    dbExecute(con, "INSERT INTO fossils (species, age, location) VALUES (?, ?, ?)", 
              params = list(species, age, location))
  })
  
  # Fosil kayıtlarını gösterme işlevi
  output$fossil_table <- renderTable({
    dbGetQuery(con, "SELECT * FROM fossils")
  })
  
  # Arama işlevi
  observeEvent(input$search_button, {
    search_query <- paste0("SELECT * FROM fossils WHERE species LIKE '%", input$search, "%'")
    searched_data <- dbGetQuery(con, search_query)
    output$fossil_table <- renderTable({
      searched_data
    })
  })
  
  # Sonuçları indirme işlevi
  output$download <- downloadHandler(
    filename = function() {
      paste("fossil_search_results", ".csv", sep = "")
    },
    content = function(file) {
      write.csv(dbGetQuery(con, "SELECT * FROM fossils"), file)
    }
  )
}

# Run the application 
shinyApp(ui = ui, server = server)
