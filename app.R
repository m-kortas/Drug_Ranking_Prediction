library(data.table)
library(DT)
library(shinydashboard)
library(plyr)
library(scales)
library(wordcloud)
library(syuzhet)
library(tidyverse)
library(XML)
library(RCurl)
library(tidyr)
library(tm)
library(SnowballC)
library(RColorBrewer)
library(rtweet)
library(e1071)
library(httpuv)
library(plotly)
library(dplyr)
library(shinydashboardPlus)
library(shinycssloaders)
library(ggplot2)
library(topicmodels)
library(tidytext)

data_loading2 <- function() {   
  
  shiny_data <<- read.csv("shiny_data.csv", row.names=1)
  shiny_data_final <<- shiny_data %>% select(urlDrugName, rating, y_pred, condition) 
  shiny_data_final$rating <<- as.double(shiny_data_final$rating)
  ranking_final <<- shiny_data_final %>% group_by(urlDrugName, condition) %>% summarize(Average_Rating = mean(rating), 
                                                                                        Average_Sentiment_Rating = mean(y_pred), n_reviews= n()) 
  test_data <<- read.delim("test_data.tsv", comment.char="#")
}

data_loading3 <- function() { 
  
  p <- function(v) {
    Reduce(f=paste, x = v)
  }
  
  data <- test_data %>% 
    group_by(urlDrugName)  %>% 
    mutate(benefits=p(benefitsReview), sideef = p(sideEffectsReview), total = p(commentsReview)) 
  
  data_for_emotions <<- data %>% group_by(urlDrugName) %>% select(urlDrugName, benefits, sideef, total) 
  
}
data_loading2()
data_loading3()

ui <- dashboardPagePlus(
  skin = "blue",
  dashboardHeaderPlus(title = ""),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    tags$head(tags$style(HTML('
                              .content-wrapper, .right-side  {
                              background-color: #ffffff;
                              }
                              .skin-blue .main-sidebar {
                              background-color: 		#368BC1;
                              color: #ffffff;
                              }
                              .skin-blue .main-sidebar .sidebar .sidebar-menu .active a{
                              background-color: 		#368BC1;
                              }
                              .skin-blue .main-sidebar .sidebar .sidebar-menu a{
                              background-color: 		#368BC1;
                              color: #000000;
                              }
                              .skin-blue .main-header .logo {
                              background-color: 	#368BC1;
                              }
                              
                              .skin-blue .main-header .logo:hover {
                              background-color: 	#368BC1;
                              }
                              
                              .skin-blue .main-header .navbar {
                              background-color: 	#368BC1;
                              }
                              '))),
    
    fluidRow(),
    fluidRow( img(src='https://i.ibb.co/PYNHQqw/drugs.png', align = "right") , 
    widgetUserBox(
                title = "Drugs Ranking",
                subtitle = "Find best drug for your health issue based on patient's reviews (rating and comments' sentiment)!",
                width = 6,
                type = 2,
                src = "",
                color = "light-blue"
                ,
                selectInput(inputId = "problem", label = "Select condition and we will find the best drug for your condition!", 
                            choices = ranking_final$condition, multiple = FALSE,
                            selectize = TRUE, width = NULL, size = NULL),
                selectInput(inputId = "drug", label = "Select drug to read more what people think about it. ", 
                            choices = ranking_final$urlDrugName, multiple = FALSE,
                           selectize = TRUE, width = NULL, size = NULL)
                )
              ),
    fluidRow(box(
      title = "Best drugs for your condition", width = 6, background = "light-blue",
      withSpinner(plotlyOutput("drugs"),  type = getOption("spinner.type", default = 6),
                  color = getOption("spinner.color", default = "#ffffff"))
    ), box(
      title = "Chosen drug's last review", width = 6, background = "light-blue",
      withSpinner(dataTableOutput("review"),  type = getOption("spinner.type", default = 6),
                  color = getOption("spinner.color", default = "#ffffff"))
    )),
    
    fluidRow(box(
      title = "Which problems chosen drug heals the best", width = 6, background = "light-blue",
      withSpinner(plotlyOutput("ill"),  type = getOption("spinner.type", default = 6),
                  color = getOption("spinner.color", default = "#ffffff"))), 
      
      box(title = "Emotions related to chosen drug", width = 6, background = "light-blue",
          withSpinner(plotlyOutput("emotions"),  type = getOption("spinner.type", default = 6),
                      color = getOption("spinner.color", default = "#ffffff"))
      )
    ),
    fluidRow(box(
      title = "Wordcloud - chosen drug's side effects", width = 6, background = "light-blue",
      withSpinner(plotOutput("sideeff_wordcloud"),  type = getOption("spinner.type", default = 6),
                  color = getOption("spinner.color", default = "#ffffff"))
    ), box(
      title = "Wordcloud - chosen drug's benefits", width = 6, background = "light-blue",
      withSpinner(plotOutput("benefits_wordcloud"),  type = getOption("spinner.type", default = 6),
                  color = getOption("spinner.color", default = "#ffffff"))
    )),
    
    fluidRow(widgetUserBox(
      title = "Magdalena Kortas",
      subtitle = "The Author",
      width = 12,
      type = 2,
      src = "https://i.ibb.co/zbqcbkX/0.jpg",
      color = "light-blue",
      "Data Science & Data storytelling enthusiast. Women in Machine Learning & Data Science (WiML&DS) team member. 
      Write me on",  tags$a(href="mailto:magdalenekortas@gmail.com", "magdalenekortas@gmail.com"), "or find me on",
      tags$a(href="https://www.linkedin.com/in/mkortas/", "Linkedin."), ""
    ))
    )
    )

server <- function(input, output, session) {
  

  output$drugs <- renderPlotly({
    plotdrugs <- ranking_final %>% filter(condition ==  input$problem) %>% arrange(desc(Average_Rating),desc(Average_Sentiment_Rating))  %>% head(5) 
    plotdrugs %>%
      ggplot(aes(reorder(urlDrugName,Average_Rating), Average_Rating, fill = Average_Sentiment_Rating)) +
      geom_col(show.legend = TRUE) +
      xlab("Drug name") +
      ylab("Average overall ranking") +
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
    
    
  })
  
  output$ill <- renderPlotly({
    
    unique(data_for_emotions) %>% filter(urlDrugName ==  input$drug) -> data_for_emotions2
    
    ranking_final %>% filter(urlDrugName  ==  input$drug) -> illness
    illness %>%
      ggplot(aes(reorder(condition,Average_Rating), Average_Rating, fill = Average_Sentiment_Rating)) +
      geom_col(show.legend = TRUE) +
      xlab("Illness") +
      ylab("Average overall ranking") +
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
    
    
  })
  
  output$emotions <- renderPlotly({
    
  
    unique(data_for_emotions) %>% filter(urlDrugName ==  input$drug) -> data_for_emotions2
    
    dane3 <- data_for_emotions2$total
    docs <- Corpus(VectorSource(dane3))
    docs <- tm_map(docs, tolower) 
    docs <- tm_map(docs, removeNumbers) 
    docs <- tm_map(docs, removeWords, stopwords("english")) 
    docs <- tm_map(docs, removePunctuation) 
    docs <- tm_map(docs, stripWhitespace) 
    dtm <- TermDocumentMatrix(docs)    
    m   <- as.matrix(dtm)                   
    v   <- sort(rowSums(m), decreasing=TRUE)   
    d   <- data.frame(word=names(v), freq=v) 
    df_sentiment<-get_nrc_sentiment(as.String(d$word)) 
    df_sentiment_transposed <- t(df_sentiment)
    df_sentiment_final <- data.frame(sentiment=row.names(df_sentiment_transposed),sent_value=df_sentiment_transposed, row.names=NULL) 
    df_emotions <<- df_sentiment_final[1:8,] 
    
   ggplot(data= df_emotions, mapping= aes(x=sentiment, y = sent_value, color=sentiment, fill = sentiment))+
               geom_bar(stat="identity") +
               xlab("Emotions connected to the pill")+
               ylab("Value") +
               theme(axis.text.x=element_text(angle=90, hjust=1))
    
    
  })
  
  output$benefits_wordcloud <- renderPlot({
    
    
    unique(data_for_emotions) %>% filter(urlDrugName ==  input$drug) -> data_for_emotions2
    
    
    dane3 <- data_for_emotions2$benefits
    docs <- Corpus(VectorSource(dane3))
    docs <- tm_map(docs, tolower) 
    docs <- tm_map(docs, removeNumbers) 
    docs <- tm_map(docs, removeWords, stopwords("english")) 
    docs <- tm_map(docs, removePunctuation) 
    docs <- tm_map(docs, stripWhitespace) 
    dtm <- TermDocumentMatrix(docs)    
    m   <- as.matrix(dtm)                   
    v   <- sort(rowSums(m), decreasing=TRUE)   
    d   <- data.frame(word=names(v), freq=v) 
    
    wordcloud(words = d$word, freq = d$freq, min.freq = 1, 
              max.words = 15, random.order = FALSE, rot.per = 0.1, colors = brewer.pal(8,"Dark2")) 
    
    
  })
  
  output$sideeff_wordcloud <- renderPlot({
   
    unique(data_for_emotions) %>% filter(urlDrugName ==  input$drug) -> data_for_emotions2
    
    dane3 <- data_for_emotions2$sideef
    docs <- Corpus(VectorSource(dane3))
    docs <- tm_map(docs, tolower) 
    docs <- tm_map(docs, removeNumbers) 
    docs <- tm_map(docs, removeWords, stopwords("english")) 
    docs <- tm_map(docs, removePunctuation) 
    docs <- tm_map(docs, stripWhitespace) 
    dtm <- TermDocumentMatrix(docs)    
    m   <- as.matrix(dtm)                   
    v   <- sort(rowSums(m), decreasing=TRUE)   
    d   <- data.frame(word=names(v), freq=v) 
    
    wordcloud(words = d$word, freq = d$freq, min.freq = 1, 
              max.words = 15, random.order = FALSE, rot.per = 0.1, colors = brewer.pal(8,"Dark2")) 
    
    
  })
  
  output$review <- renderDataTable(
    
    
    formatStyle(datatable(test_data %>% filter(urlDrugName ==  input$drug) %>% 
                  arrange(desc(X)) %>% head(1) %>% select(benefitsReview, sideEffectsReview, commentsReview)), columns = 1:4, color = "black")
    
    
    
    
  )
  
}





shinyApp(ui = ui , server = server)