
library(shiny)
library(dplyr); library(ngram); library(tidytext);library(tidyr)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  text<-readRDS("./en_US/twitter.rds")
  text_blogs<-readRDS("./en_US/blogs.rds")
  text_news<-readRDS("./en_US/news.rds")
  
  set.seed(1)
  text<-sample(text, size=length(text)*0.02) # 2 percent of the data
  text_blogs<-sample(text_blogs, size=length(text_blogs)*0.02) # 2 percent of the data
  text_news<-sample(text_news, size=length(text_news)*0.02) # 2 percent of the data
  text<-c(text,text_blogs,text_news)
  
  text.sub<-gsub("\\.|\\?|\\,|\\!|\\d","", text)
  profanity<-readLines(file("./en_US/profanity.txt", "r"))
  profanity<-gsub(" ", "|", profanity)
  text.sub<-gsub(paste(profanity), "", text.sub)
  text.sub<-tolower(text.sub)
  text.sub<-iconv(text.sub,to="ASCII//TRANSLIT")
  
  text_df<-data_frame(line=1:length(text.sub),text=text.sub)
  
  text_bigrams<-text_df%>%
    unnest_tokens(bigram,text,token="ngrams",n=2)%>%
    count(bigram, sort=TRUE)%>%
    separate(bigram, c("word1", "word2"), sep=" ")
  text_trigrams<-text_df%>%
    unnest_tokens(trigram,text,token="ngrams",n=3)%>%
    count(trigram, sort=TRUE)%>%
    separate(trigram, c("word1", "word2", "word3"), sep=" ")
  
  # Reactive textbox fxn here
  pred_word<-function(x){
    if (length(grep(" ", x))>0){
      string_split<-strsplit(x," ")
      string_last_two<-length(string_split[[1]])
      get_word1<-grep(string_split[[1]][string_last_two-1],text_trigrams$word1, value = FALSE)
      get_word2<-grep(string_split[[1]][string_last_two],text_trigrams$word2, value = FALSE)
      get_word_indices<-intersect(get_word1,get_word2)
      if (is.na(text_trigrams$word3[get_word_indices[1]])==TRUE){ 
        print("*No word can be predicted*")
      } else {cat(x,text_trigrams$word3[get_word_indices[1]])}
    } else {
      get_word2<-grep(x, text_bigrams$word1, value = FALSE) # Draw out index containing x
      next_word<-text_bigrams$word2[get_word2[1]] # display the next predicted word  
      if (is.na(next_word)==TRUE){ print("*No word can be predicted*")
      } else {cat(x,next_word)}
    }
  }
  pred_more<-function(x){
    if (length(grep(" ", x))>0){
      string_split<-strsplit(x," ")
      string_last_two<-length(string_split[[1]])
      get_word1<-grep(string_split[[1]][string_last_two-1],text_trigrams$word1, value = FALSE)
      get_word2<-grep(string_split[[1]][string_last_two],text_trigrams$word2, value = FALSE)
      get_word_indices<-intersect(get_word1,get_word2)
      if (is.na(text_trigrams$word3[get_word_indices[1]])==TRUE){ 
      } else {print(c(text_trigrams$word3[get_word_indices[2]],
                      text_trigrams$word3[get_word_indices[3]],
                      text_trigrams$word3[get_word_indices[4]]))}
    } else {
      get_word2<-grep(x, text_bigrams$word1, value = FALSE) # Draw out index containing x
      next_word<-text_bigrams$word2[get_word2[1]] # display the next predicted word  
      if (is.na(next_word)==TRUE){ 
      } else {print(c(text_bigrams$word2[get_word2[2]],
                      text_bigrams$word2[get_word2[3]],
                      text_bigrams$word2[get_word2[4]]))}
    }
  }
  
  output$text1 <- renderPrint({ 
    pred_word(input$text2)
    })
  output$text3<-renderPrint({
    pred_more(input$text2)
  })
})


