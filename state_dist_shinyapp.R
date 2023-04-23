install.packages("dplyr")
install.packages("ggplot2")
install.packages("reshape2")
install.packages("descr")
install.packages("readr")
install.packages("tidyverse")
install.packages("lubridate")
install.packages("shiny")
install.packages("ggalluvial")


require(dplyr)
require(ggplot2)
require(reshape2)
library(descr)
library(readr)
library(tidyverse)
require(lubridate)
require(shiny)
require(ggalluvial)

#
QandC%>%
  mutate(mask=month(AskedOnUtc, label=FALSE, abbr=FALSE),
         yask=year(AskedOnUtc),
         ym = as.Date(paste0(mask,"-1-",yask),
                      format ="%m-%d-%Y")) %>% 
  filter(yask<2023 & yask >2012)->temp


ggplot(data=attorneytimeentries)+
  stat_summary(aes(x=StateAbbr, y=Hours), fun="mean", geom="bar")



QandC$ymdask<-as.Date(QandC$AskedOnUtc, format="%Y-%m-%d")

QandC$ymask<-as.Date(QandC$AskedOnUtc, format="%Y-%m")

QandC %>%
  group_by(ymdask, Category) %>% 
  summarize(sum=n()) %>%
  ggplot()+
  geom_area(aes(x=ymdask, y=sum,fill=Category))

"3-1-2020"

QandC%>%
  mutate(mask=month(AskedOnUtc, label=FALSE, abbr=FALSE),
         yask=year(AskedOnUtc),
         ym = as.Date(paste0(mask,"-1-",yask),
                      format ="%m-%d-%Y")) %>% 
  group_by(ym, Category) %>% 
  summarize(sum=n())%>%
  ggplot()+
  geom_area(aes(x=ym, y=sum,fill=Category))

QandC%>%
  mutate(mask=month(AskedOnUtc, label=FALSE, abbr=FALSE),
         yask=year(AskedOnUtc),
         ym = as.Date(paste0(mask,"-1-",yask),
                      format ="%m-%d-%Y")) %>% 
  filter(yask<2022 & yask >2012) %>% 
  group_by(mask, Category) %>% 
  summarize(sum=n())%>%
  ggplot()+
  geom_bar(aes(x=as.factor(mask), y=sum), stat = "identity")+
  facet_grid(.~Category)


QandC%>%
  mutate(mask=month(AskedOnUtc, label=FALSE, abbr=FALSE),
         yask=year(AskedOnUtc),
         ym = as.Date(paste0(mask,"-1-",yask),
                      format ="%m-%d-%Y")) %>% 
  filter(yask<2023 & yask >2012)->temp  


# Proportions revealed there wasn't too much of a change
QandC %>%
  mutate(mask = month(AskedOnUtc, label=FALSE, abbr=FALSE),
         yask = year(AskedOnUtc),
         ym = as.Date(paste0(mask,"-1-",yask), format ="%m-%d-%Y")) %>%
  filter(yask < 2022 & yask > 2012) %>%
  group_by(ym, Category) %>%
  summarize(count = n()) %>%
  ungroup() %>%
  group_by(ym) %>%
  mutate(total_count = sum(count)) %>%
  mutate(prop = count / total_count) %>%
  filter(Category=="Other") %>% 
  ggplot() +
  geom_line(aes(x = ym, y = prop), stat = "identity") +
  facet_grid(.~Category)



################Shiny
ui <- fluidPage(
  selectInput("state", "Choose a state:", choices = unique(QandC$StateName)),
  plotOutput("plot"))



shinyApp(ui = ui, server = server) ### SUM OF CATEGORY BY STATE OVER MONTHS

server <- function(input, output) {
  
  output$plot <- renderPlot({
    QandC %>%
      filter(StateName == input$state)->QCshiny
    
    QCshiny%>%
      mutate(mask=month(AskedOnUtc, label=FALSE, abbr=FALSE),
             yask=year(AskedOnUtc),
             ym = as.Date(paste0(mask,"-1-",yask),
                          format ="%m-%d-%Y")) %>% 
      filter(yask<2022 & yask >2012) %>% 
      group_by(mask, Category) %>% 
      summarize(sum=n())%>%
      ggplot()+
      geom_bar(aes(x=as.factor(mask), y=sum, fill=Category), stat = "identity")+
      facet_grid(.~Category)
  })
}
shinyApp(ui = ui, server = server2) ### NOT WORKING

#Other Category breakdown
server2 <- function(input, output) {
  
  output$plot <- renderPlot({
    QandC %>%
      filter(StateName == input$state, Category == "Other") %>% 
      group_by(Subcategory) %>% 
      count() %>% 
      arrange(desc(n)) %>% 
      top_n(5,n)->QCshiny2
    
    QCshiny2 %>%
      mutate(mask=month(AskedOnUtc, label=FALSE, abbr=FALSE),
             yask=year(AskedOnUtc),
             ym = as.Date(paste0(mask,"-1-",yask), format ="%m-%d-%Y")) %>% 
      filter(yask<2022 & yask >2012) %>% 
      group_by(ym, Subcategory) %>% 
      summarize(sum=n()) %>%
      top_n(5, sum) %>%
      ggplot()+
      geom_bar(aes(x=as.factor(ym), y=sum, fill=Subcategory), stat = "identity")+
      facet_grid(.~Subcategory)
  })
}
shinyApp(ui = ui, server = server3) ### SUM OF QUESTIONS BY MONTH BY STATE





server3 <- function(input, output) {
  
  output$plot <- renderPlot({
    QandC %>%
      filter(StateName == input$state)->QCshiny
    
    QCshiny%>%
      mutate(mask=month(AskedOnUtc, label=FALSE, abbr=FALSE),
             yask=year(AskedOnUtc),
             ym = as.Date(paste0(mask,"-1-",yask),
                          format ="%m-%d-%Y")) %>% 
      filter(yask<2022 & yask >2012) %>% 
      group_by(mask) %>% 
      summarize(sum=n())%>%
      ggplot()+
      geom_bar(aes(x=as.factor(mask), y=sum), stat = "identity")  
  })
}

################# Shiny Test of Other Subcategories
QandC %>%
  filter(StateName == "Texas", Category == "Other") %>% 
  group_by(Subcategory) %>% 
  count() %>% 
  arrange(desc(n)) %>% 
  top_n(5,n)->QCshiny2

##############graph: Percentage of cases by categories for each state (NOT WORKING/MISSING CODE)

QandC %>%
  group_by(Category, StateAbbr.x) %>%
  summarize(state_cat_count = n()) %>%
  group_by() %>% 
  mutate() %>% 
  mutate(prop = count / total_count) %>%
  filter(Category=="Family and Children") %>% 
  ggplot() +
  geom_bar(aes(x=StateAbbr.x,y = prop), stat="identity")


############# Category Proportions asked by State
QandC %>% 
  group_by(StateAbbr.x, Category) %>%
  summarize(state_cat_sum=n()) %>% 
  group_by(StateAbbr.x) %>% 
  mutate(state_sum = sum(state_cat_sum)) %>% 
  mutate(prop = state_cat_sum/state_sum) %>% 
  ggplot()+
  geom_bar(aes(x=StateAbbr.x,y=prop,fill=Category), stat="identity", position="fill")


################# Proportions Outline
# Questions answered or not
QandC %>%
  group_by(StateAbbr.x) %>% 
  mutate(answered=(if_else(TakenByAttorneyUno=="NULL",0,1))) %>% 
  summarize(prop=mean(answered, na.rm=TRUE)) %>% 
  arrange(desc(prop))->QC_answer

#Proportion of taken questions per state


QC_answer%>%
  mutate(states=factor(StateAbbr.x, levels=c(QC_answer$StateAbbr.x))) %>% 
  ggplot(aes(x=states, y=prop)) +
  geom_bar(stat="identity") +
  geom_text(aes(label=paste0(round(prop,2)*100,"%"), vjust=-0.2))

####################### ALLUVIAL BY STATE BY CATEGORY ANSWERED VS NOT ANSWERED
shinyApp(ui = ui_AV, server = server_AV) 

ui_AV <- fluidPage(
  selectInput("state", "Choose a state:", choices = unique(QandC$StateName),
              selected="California"),
  selectInput("cat","Choose categories of interest",
              choices=unique(QandC$Category),
              selected="Family and Children",
              multiple = TRUE),
  plotOutput("plot"))

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

########## ALl Category Alluvial
QandC %>%
  mutate(answered=(if_else(TakenByAttorneyUno=="NULL","Unanswered","Answered"))) %>%
  group_by(Category, answered) %>% 
  summarize(cat_sum=n()) %>% 
  group_by(answered) %>% 
  ggplot(aes(axis1 = Category,
             axis2 = answered,
             y = cat_sum, fill=Category)) +
  geom_alluvium(aes(fill = Category)) +
  geom_stratum()+
  geom_label(stat = "stratum", aes(label = after_stat(stratum))) +
  scale_x_discrete(limits = c("Category", "Answered")) +
  xlab("Lable here") +
  ggtitle("This is an alluvial of Category answered or not")

############# Sub categories Alluvial
QandC %>%
  filter(Category=="Family and Children") %>% 
  mutate(answered=(if_else(TakenByAttorneyUno=="NULL","Unanswered","Answered"))) %>%
  group_by(Subcategory, answered) %>% 
  summarize(cat_sum=n()) %>% 
  group_by(answered) %>% 
  arrange(desc(cat_sum))

QandC %>%
  filter(Category == "Family and Children") %>% 
  mutate(answered = if_else(TakenByAttorneyUno == "NULL", "Unanswered", "Answered")) %>%
  group_by(Subcategory, answered) %>% 
  summarize(cat_sum = n()) %>% 
  group_by(answered) %>%
  mutate(prop = cat_sum / sum(cat_sum)) %>%
  arrange(desc(prop)) %>%
  ungroup()






server_AV <- function(input, output) {
  
  output$plot <- renderPlot({
    QandC %>%
      filter(StateName==input$state) %>% 
      mutate(answered=(if_else(TakenByAttorneyUno=="NULL","Not Taken","Taken"))) %>%
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
      xlab("Category to Taken and") +
      ylab("Sum of All selected Category Questions")+
      ggtitle("Proportion of Questions Taken by Attorneys Based on Category and State")+
      theme(text = element_text(size = 18))
  })
}

merge_with_time %>% 
  summarise(count = count(TrueTimeSpentMinutes)) %>% 
  ggplot(aes(x = TrueTimeSpentMinutes, y = count)) +
  geom_bar(stat = "identity") +
  xlab("Time") +
  ylab("Frequency of Time") +
  ggtitle("Frequency of Time by Question Count")+
  scale_fill_gradient(low = "#14fbbb", high = "black")+
  guides(fill = FALSE)











