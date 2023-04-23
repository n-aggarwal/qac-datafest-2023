# Install and load required packages
install.packages(c("shiny", "dplyr", "ggplot2", "reshape2", "descr", "readr", "tidyverse", "lubridate", "ggalluvial"))
library(shiny)
library(dplyr)
library(ggplot2)
library(reshape2)
library(descr)
library(readr)
library(tidyverse)
library(lubridate)
library(ggalluvial)

# Load the data
QandC <- read_csv("QandC.csv")


####################### ALLUVIAL BY STATE BY CATEGORY ANSWERED VS NOT ANSWERED
QandC %>%
  group_by(StateAbbr.x) %>% 
  mutate(answered=(if_else(TakenByAttorneyUno=="NULL",0,1))) %>% 
  summarize(prop=mean(answered, na.rm=TRUE)) %>% 
  arrange(desc(prop))->QC_answer


server_AV <- function(input, output) {
  
  output$plot <- renderPlot({
    QandC %>%
      filter(StateName==input$state) %>% 
      mutate(answered=(if_else(TakenByAttorneyUno=="NULL","Unanswered","Answered"))) %>%
      group_by(StateName, Category, answered) %>% 
      summarize(state_cat_sum=n()) %>% 
      group_by(StateName, answered) %>% 
      mutate(state_sum = sum(state_cat_sum)) %>% 
      filter(Category%in%c(input$cat)) %>% 
      ggplot(aes(axis1 = Category,
                 axis2 = answered,
                 y = state_cat_sum, fill=Category)) +
      geom_alluvium(aes(fill = Category)) +
      geom_stratum()+
      geom_label(stat = "stratum", aes(label = after_stat(stratum))) +
      scale_x_discrete(limits = c("Category", "Answered")) +
      xlab("Lable here") +
      ggtitle("This is an alluvial of Category answered or not")
  })
}

ui_AV <- fluidPage(
  selectInput("state", "Choose a state:", choices = unique(QandC$StateName),
              selected="California"),
  selectInput("cat","Choose categories of interest",
              choices=unique(QandC$Category),
              selected="Family and Children",
              multiple = TRUE),
  plotOutput("plot"))

shinyApp(ui = ui_AV, server = server_AV) 







