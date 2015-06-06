library(shiny)
library(XML)
library(RCurl)
library(dplyr)
library(ggplot2)
library(scales)

source("global.R")

thm <- function() {
  theme_gray(base_family = "STHeiti") + # 讓Mac使用者能夠顯示中文, Windows使用者應省略這行
    theme(text=element_text(size=18)) # 將字體調整至18號
}
rain<-rbind(dat,rain)
shinyServer(function(input, output) {
  #檢查資料更新狀況
  
  if (grepl(0.0001,rain[as.character(rain$V1)==(Sys.Date()-1),2])==TRUE) {
    year<-format(Sys.Date(),format="%Y")
    rain<-getrain(year)
    rain<-rbind(dat,rain)
  }
  
  output$plotyear <- renderPlot({

    ggplot(filter(rain,format(rain$V1,format="%Y")==input$years),aes(x=V1,y=V2))+
      geom_line()+
      labs(x="日期", y="雨量") + thm() + 
      scale_x_date(labels=date_format("%m"), breaks = date_breaks("1 month"))

  })

})
