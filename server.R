#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

 #read data 
  freqTerms_sorted <- readRDS("freqTerms_sorted.RData")
  
  
  results <- reactive({
    
  # Predictive model
    input_code <- tolower(input$input_text)
   # input_code <- c("would like to thank")
    number_of_words <- sapply(strsplit(input_code, " "), length)
    i <- number_of_words
    # cut longer then 4 strings - model has only 5-grams max
    if (i > 4) { input_cut <- tail(strsplit(input_code, split=" ")[[1]],4)
    input_code <- paste(input_cut[1], input_cut[2], input_cut[3], input_cut[4], sep = " ")
    number_of_words <- sapply(strsplit(input_code, " "), length)
    i <- number_of_words
    } else {}
    # searching for all matches in DB
    input_freq <- freqTerms_sorted[grep(paste("^", input_code, " .", sep=""), freqTerms_sorted[,i[1]]),]
    # cutting first world if no 3 matches in the longest gram
   while (length(input_freq) < 12 && number_of_words > 1) {
      
      input_code <- sub(".*? ", "", input_code)
      number_of_words <- sapply(strsplit(input_code, " "), length)
      i <- number_of_words 
      input_freq <- freqTerms_sorted[grep(paste("^", input_code, " .", sep=""), freqTerms_sorted[,i[1]]),]
    } 
    # info if no matches even for 2-grams


    
if (length(input_freq) < 1){
                            top_3 <- c("","","") 
                            top_3
                            } else {

                           
    # subseting top 3 matches
    top_3 <- input_freq[1:3,i[1]]
    # subseting last world from top3 matches
    top_3 <- sapply(strsplit(top_3, split = " "), last) 
    top_3 }
    
  })
 
# button 1  
  output$one <- renderUI({
    actionButton("top1", label = results()[1])
  })
  observeEvent(input$top1,{
      updated_text <- paste(input$input_text,results()[1])
      updateTextInput(session, "input_text", value = updated_text)
  })
  
#button 2  
  output$two <- renderUI({
    actionButton("top2", label = results()[2])
  })
  observeEvent(input$top2,{
    updated_text <- paste(input$input_text,results()[2])
    updateTextInput(session, "input_text", value = updated_text)
  })
  
  
#button 3  
  output$three <- renderUI({
    actionButton("top3", label = results()[3])
  })
  observeEvent(input$top3,{
    updated_text <- paste(input$input_text,results()[3])
    updateTextInput(session, "input_text", value = updated_text)
  })
  
  

  
})
  
  


