library(tm)
library(shiny)
library(wordcloud)
library(memoise)
# Source example: https://shiny.rstudio.com/gallery/word-cloud.html

data <- read.csv("topten.csv")
colnames(data) <- c("Rank", "Collaborator", "Title")
top10 <- data[,1]


getTermMatrix <- memoise(function(collaborator) {
  
  text <- data[collaborator,3]
  
  myCorpus = Corpus(VectorSource(text))
  myCorpus = tm_map(myCorpus, content_transformer(tolower))
  myCorpus = tm_map(myCorpus, removePunctuation)
  myCorpus = tm_map(myCorpus, removeNumbers)
  myCorpus = tm_map(myCorpus, removeWords,
                    c(stopwords("SMART"), "the", "and", "but"))
  
  myDTM = TermDocumentMatrix(myCorpus,
                             control = list(minWordLength = 1))
  
  m = as.matrix(myDTM)
  
  sort(rowSums(m), decreasing = TRUE)
})

ui <- fluidPage(
   
   # Application title
   titlePanel("Top UNC Collaborators and Topics of Collaboration"),
   
   # Sidebar with selection to see topics by collaborator rank
   sidebarLayout(
      sidebarPanel(
        radioButtons("number", "Rank number",
                     c("1","2","3","4","5","6","7","8","9","10")),
        actionButton("update", "View Topics")
      
        
        
      ),
      
      # Show a word cloud of the topics of collaboration and data table of ranked collaborators
      mainPanel(
        h2("Main topics of collaboration"),
        plotOutput("plot"),
        h2("Ranked list of collaborators"),
        dataTableOutput(outputId = "collabTable")
      )
   )
)

# Define server logic 
server <- function(input, output) {
  
  # Define a reactive expression for the document term matrix
  terms <- reactive({
    # Change when the "update" button is pressed...
    input$update
    # ...but not for anything else
    isolate({
      withProgress({
        setProgress(message = "Processing corpus...")
        getTermMatrix(input$number)
      })
    })
  })
  
  wordcloud_rep <- repeatable(wordcloud)
  
  output$plot <- renderPlot({
    v <- terms()
    wordcloud_rep(names(v), v, scale=c(4,0.5),
                  colors=brewer.pal(8, "Dark2"))
   
  })
 
   output$collabTable <- renderDataTable({data[,1:2]})
}

# Run the application 
shinyApp(ui = ui, server = server)

