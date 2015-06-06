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
    #存檔
    path<-paste("data/",year,"_rain.csv",sep="")
    write.csv(rain,file = path ,fileEncoding="UTF-8",row.names=FALSE)
    
    rain<-rbind(dat,rain)
  }
  
  rain2<-filter(rain,V2!=0.0001)
  
  output$plot1 <- renderPlot({

    ggplot(filter(rain2,format(rain2$V1,format="%Y")==input$years),aes(x=V1,y=V2))+
      geom_line(colour="blue")+
      labs(x="日期", y="雨量") + thm() + 
      scale_x_date(labels=date_format("%m"), breaks = date_breaks("1 month"))

  })
  
  output$plot2 <- renderPlot({
    
    ggplot(filter(rain2,format(rain2$V1,format="%Y")==input$years,format(rain2$V1,format="%m")==input$month),aes(x=V1,y=V2))+
      geom_line(colour="blue")+
      labs(x="日期", y="雨量") + thm() + 
      scale_x_date(labels=date_format("%d"), breaks = date_breaks("1 days"))
    
  })
  
  output$table<-renderDataTable(filter(rain2,format(rain2$V1,format="%Y")==input$years)) 

})

