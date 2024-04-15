#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:

# Gerekli kütüphaneleri yükle
# Gerekli kütüphaneleri yükle
library(shiny)
library(DBI)
library(RSQLite)
library(openxlsx)

# Veritabanı bağlantısını oluştur
con <- dbConnect(RSQLite::SQLite(), "my_database.db")

# UI tanımı
ui <- fluidPage(
  titlePanel("Fossil Database"),
  sidebarLayout(
    sidebarPanel(
      textInput("species", "Species:"),
      textInput("country", "Country:"),
      textInput("site", "Site:"),
      numericInput("latitude", "Latitude:", value = NULL),
      numericInput("longitude", "Longitude:", value = NULL),
      textInput("date", "Date:"),
      textInput("dating_method", "Dating Method:"),
      textInput("calibrated_dating_range", "Calibrated Dating Range:"),
      numericInput("lower_dating_interval_BC", "Lower Dating Interval BC:", value = NULL),
      numericInput("upper_dating_interval_BC", "Upper Dating Interval BC:", value = NULL),
      textInput("reference", "Reference:"),
      textInput("comments", "Comments:"),
      textInput("data_source", "Data Source:"),
      actionButton("submit", "Add Record"),
      br(),
      textInput("search", "Search:"),
      actionButton("search_button", "Search"),
      br(),
      fileInput("file", "CSV File:", accept = ".csv"),  # Dosya yükleme alanı
      br(),
      downloadButton("download_template", "Download Template"),  # Taslak indirme butonu
      br(),
      downloadButton("download", "Download Results")
    ),
    mainPanel(
      br(),
      tabsetPanel(
        tabPanel("Recently Added Records", 
                 h3("Recently Added Records"),
                 tableOutput("recent_fossils")),
        tabPanel("Search Results", 
                 h3("Search Results"),
                 tableOutput("search_result_table"))
      )
    )
  )
)


# Server tanımı
server <- function(input, output, session) {
  
  # Veritabanındaki verileri yükle
  output$recent_fossils <- renderTable({
    recent_data <- dbGetQuery(con, "SELECT * FROM fossils ORDER BY SampleID DESC LIMIT 20")
    recent_data
  })
  
  # Dosya yükleme işlemini gerçekleştir
  observeEvent(input$file, {
    req(input$file) # Dosya yükleme işlemi başlatıldığında çalışır
    
    # Seçilen dosyayı bir veri çerçevesine oku
    data <- read.csv(input$file$datapath, header = TRUE, stringsAsFactors = FALSE)
    
    # Veriyi veritabanına yükle
    dbWriteTable(con, "fossils", data, append = TRUE, row.names = FALSE)
    
    # Kullanıcıya yükleme tamamlandı mesajını göster
    showNotification("CSV file successfully uploaded.", duration = 5)
    
    # Veritabanındaki verileri yeniden yükle
    output$recent_fossils <- renderTable({
      recent_data <- dbGetQuery(con, "SELECT * FROM fossils ORDER BY SampleID DESC LIMIT 20")
      recent_data
    })
  })
  
  # Arama sonuçlarını göster
  output$search_result_table <- renderTable({
    req(input$search_button)  # Arama düğmesine basıldığında çalıştır
    if (!is.null(input$search) && input$search_button > 0) {
      if (nchar(input$search) > 0) {
        search_query <- paste0("SELECT * FROM fossils WHERE Species LIKE '%", input$search, "%'")
        searched_data <- dbGetQuery(con, search_query)
        searched_data
      } else {
        NULL  # Boş bir sorgu kutusu durumunda hiçbir şey göster
      }
    }
  })
  
  # Sorgu kutusunu izleme
  observeEvent(input$search, {
    if (!is.null(input$search) && nchar(input$search) == 0) {
      output$search_result_table <- renderTable({
        NULL  # Sorgu kutusu boşsa hiçbir şey göster
      })
    }
  })
  
  # Sorgu işlevi
  observeEvent(input$search_button, {
    output$search_result_table <- renderTable({
      req(input$search_button)  # Arama düğmesine basıldığında çalıştır
      if (nchar(input$search) == 0) {
        NULL  # Boş bir sorgu kutusu durumunda hiçbir şey göster
      } else {
        search_query <- paste0("SELECT * FROM fossils WHERE Species LIKE '%", input$search, "%'")
        searched_data <- dbGetQuery(con, search_query)
        searched_data
      }
    })
  })
  
  # Kayıt ekleme işlevi
  observeEvent(input$submit, {
    species <- input$species
    country <- input$country
    site <- input$site
    latitude <- input$latitude
    longitude <- input$longitude
    date <- input$date
    dating_method <- input$dating_method
    calibrated_dating_range <- input$calibrated_dating_range
    lower_dating_interval_BC <- input$lower_dating_interval_BC
    upper_dating_interval_BC <- input$upper_dating_interval_BC
    reference <- input$reference
    comments <- input$comments
    data_source <- input$data_source
    
    # Kaydı veritabanına ekle
    dbExecute(con, "INSERT INTO fossils (Species, Country, Site, Latitude, Longitude, Date, Dating_method, Calibrated_Dating_range, Lower_dating_interval_BC, Upper_dating_interval_BC, Reference, Comments, Data_Source) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
              params = list(species, country, site, latitude, longitude, date, dating_method, calibrated_dating_range, lower_dating_interval_BC, upper_dating_interval_BC, reference, comments, data_source))
    
    # Durum raporu göster
    showNotification("Record successfully added.", duration = 5)
    
    # Veritabanındaki verileri yeniden yükle
    output$recent_fossils <- renderTable({
      recent_data <- dbGetQuery(con, "SELECT * FROM fossils ORDER BY SampleID DESC LIMIT 20")
      recent_data
    })
  })
  
  # Sonuçları indirme işlevi
  output$download <- downloadHandler(
    filename = function() {
      paste("fossil_search_results", ".csv", sep = "")
    },
    content = function(file) {
      write.csv(dbGetQuery(con, "SELECT * FROM fossils"), file, fileEncoding = "UTF-8")
    }
  )
}

# Uygulamayı çalıştır
shinyApp(ui = ui, server = server)
