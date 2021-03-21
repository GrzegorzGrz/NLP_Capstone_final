#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("NLP Capstone project - John Hopkins University - Data Science"),

    # Sidebar with a slider input for number of bins

    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Introducion", 
                   
                    h4("NLP Capstone project"),
                    p("This project is a part of NLP Capstone created for Data Science course delivered through Coursera"),
                    p("The main deliverables is NLP algorithm which predicts next word based on the input"),
                    p("On this page you will find two additional tabs, Text prediction model and Manual, where you can find predictove model to test and all information how the model was built respectivley"),
                   
                    br(),
                    h4("Credits"),
                    
                    a("Coursera - Data Science - John Hopkins", href="https://www.coursera.org/learn/data-science-project"),  br(),
                    a("Text Mining Infrastructure in R", href="https://www.jstatsoft.org/article/view/v025i05"),  br(),
                    a("CRAN Task View: Natural Language Processing", href="https://cran.r-project.org/web/views/NaturalLanguageProcessing.html"),
                    p("And several other video and online tutorials and examples"),
                    
                    
                  
                  ),
                  tabPanel("Text prediction model", br(),
                           p("Please type first world and then you will see 3 best predictions, please select one by cliking on it."),
                           textInput("input_text","", placeholder = "Enter text here", width= '100%'),
                           
                           div(id="predButtons",
                               uiOutput("one"),
                               uiOutput("two"),
                               uiOutput("three")
                           )
                  ),
                 
                  tabPanel("Manual", 
                  
                      h4("Data acquisition"),
                      p("Data were downloaded from the link provided by Coursera. Data set consists of 4 languages subsets, subset for each language consists 3 sourcse files: twitter, blogs, news.
                        for the purpose of this project only English data set was taken into account"),
                      p("Length of each source file (EN):"), 
                       p("Blogs 899288"), 
                        p("News 1010242"), 
                      p("Twitter 2360148"), 
                      a("Course dataset", href="https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"),  br(),
                    p(""),
               
                      h4("Data Processing"),
                    p("Model was build by randomly subsetting 15% of total data set. In order to build a Corpus it was  decided to remove from data: numbers, punctuation, non alphanumeric symbols, redundant spaces, single letters and change all letters to lower."),
                    p("In a next phase, 2,3,4,5-grams were built and top 1000 000 from each n-gram were saved to model source file"),
                    br(),
                    h4("Prediction Model"),
                    p("Model was built to select the most common n-gram starting from the longest one."),
                    br(),
                    a("Github repository with all source codes", href="https://github.com/GrzegorzGrz/NLP_Capstone_final"),br(),
                    a("Presentaion", href="https://rpubs.com/Grzegorz_Sz/NLP_Capstone"),
                  
                  
      )
      
      
    )   
    
    

)))
