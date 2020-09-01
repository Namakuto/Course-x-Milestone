
library(shiny)
library(dplyr); library(ngram); library(tidytext);library(tidyr)

shinyUI(fluidPage(
    # Application title
  titlePanel("A Predictive Text App"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      p("This app will generate predictive text based on user input. 
      It will attempt to predict what word(s) you would want to 
      type in next."),
      
      p("Instructions:"),
      p("- Type your text, all in LOWERCASE, into the textbox below."), 
      p("- Your predictive text will be generated in the panel on the right."), 
      p("- New predictions are generated for different letter combinations 
      (e.g., 'ca-' versus 'co-')"),
      
      p("Warning:"),
      p("- You will get an error upon entering an empty space (' ') 
      into the text input field. Simply proceed with typing in a letter,
      or words, and the app will keep working again."),
      
      textInput
      (
        #"text2",label=h4("Enter a word or phrase here: "),"" 
        "text2",strong("Enter a word or phrase here: "),"" 
        )
      ),
    
    mainPanel(
      h4("ENTER ALL TEXT IN LOWERCASE."),
      "______________________________________________________________",
       textOutput("text1"),
      tags$head(tags$style("#text3{color:gray;}")),
      "______________________________________________________________",
      h4("Next top three predicted words for you: "),
      textOutput("text3")
    )
  )
))
