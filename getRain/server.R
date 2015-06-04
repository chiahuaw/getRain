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
#設定今年
year<-format(Sys.Date(),format="%Y")

#讀入以前年度的雨量資料

rm(dat)
dat<-data.frame()

for (y in 2006:(as.numeric(year)-1)) {
  path<-paste("data/",y,"_rain.csv",sep="")
  f<-file(path)
  a<-read.csv(f)
  dat<-rbind(dat,a)
}

dat<-dat[,-1]
dat[,1]<-as.Date(dat[,1])

#設定中央氣象局今年每日雨量資料連結
url_list <- list()
url_list <- paste('http://www.cwb.gov.tw/V7/climate/dailyPrecipitation/Data/467110_',year,'.htm',sep='')
url_list <- unlist(url_list)


shinyServer(function(input, output) {
rm(rain)
  #判斷今年有無已抓取的雨量資料
  if (format(Sys.Date(),format="%m-%d")=="01-01") {
    rain<-c(Sys.Date(),0.0001) }
  if (format(Sys.Date(),format="%m-%d")!="01-01") {
  
  if (system(paste("ls data/",year,"_rain.csv",sep=""))==0) {
    path<-paste("data/",year,"_rain.csv",sep="")
    f<-file(path)
    rain<-read.csv(f)
    rain<-rain[,-1]
    rain[,1]<-as.Date(rain[,1])
    #存檔
    path<-paste("data/",year,"_rain.csv",sep="")
    write.csv(rain,file = path ,fileEncoding="UTF-8")
  }
  if (system(paste("ls data/",year,"_rain.csv",sep=""))!=0) { #若無，直接抓取今年的雨量資料
    
    get_url <- getURL(url_list,encoding = "UTF-8")
    get_url_parse <- htmlParse(get_url, encoding = "UTF-8")
    tablehead <- xpathSApply(get_url_parse, "//table[@class='Form00']/tr/td", xmlValue)
    Temp_Total <- matrix(tablehead, ncol = 12, byrow = TRUE)
    
    rain <- matrix(ncol = 2,nrow=384)
    rain[,2]<-matrix(Temp_Total,ncol=1)
    
    Temp1<-matrix(1:12,ncol=1,nrow=384)
    Temp1<-Temp1[order(Temp1[,1])]
    Temp2<-matrix(1:32,ncol=1,nrow=384)
    rain[,1]<- paste(year,"-",Temp1,"-",Temp2,sep="")
    
    for (i in 12:1) {
      rain<-rain[-(i*32),]
    }
    #修改空白值、"-"、"T"
    rain[rain[,2]=="-",2]<-0
    rain[rain[,2]=="T",2]<-0.05
    rain[rain[,2]=="",2]<-0.0001 #把未發生的日期的資料，填入0.0001
    rain<-as.data.frame(rain)
    rain$V1<-as.Date(rain[,1])
    rain$V2<-as.numeric(as.character((rain[,2])))
    rain<-rain[is.na(rain[,1])==F,]
    
    #存檔
    path<-paste("data/",year,"_rain.csv",sep="")
    write.csv(rain,file = path ,fileEncoding="UTF-8")
  }
  
  if (system(paste("ls data/",year,"_rain.csv",sep=""))==0) {
    day<-Sys.Date()-1
    
    if (rain[rain$V1==day,2]==0.0001) {
      
      get_url <- getURL(url_list,encoding = "UTF-8")
      get_url_parse <- htmlParse(get_url, encoding = "UTF-8")
      tablehead <- xpathSApply(get_url_parse, "//table[@class='Form00']/tr/td", xmlValue)
      Temp_Total <- matrix(tablehead, ncol = 12, byrow = TRUE)
      
      rain <- matrix(ncol = 2,nrow=384)
      rain[,2]<-matrix(Temp_Total,ncol=1)
      
      Temp1<-matrix(1:12,ncol=1,nrow=384)
      Temp1<-Temp1[order(Temp1[,1])]
      Temp2<-matrix(1:32,ncol=1,nrow=384)
      rain[,1]<- paste(year,"-",Temp1,"-",Temp2,sep="")
      
      for (i in 12:1) {
        rain<-rain[-(i*32),]
      }
      #修改空白值、"-"、"T"
      rain[rain[,2]=="-",2]<-0
      rain[rain[,2]=="T",2]<-0.05
      rain[rain[,2]=="",2]<-0.0001 #把未發生的日期的資料，填入0.0001
      rain<-as.data.frame(rain)
      rain$V1<-as.Date(rain[,1])
      rain$V2<-as.numeric(as.character((rain[,2])))
      rain<-rain[is.na(rain[,1])==F,]
      
      #存檔
      path<-paste("data/",year,"_rain.csv",sep="")
      write.csv(rain,file = path ,fileEncoding="UTF-8")
    }
  }
  
  }
  
  rain<-rbind(dat,rain)
  
  output$plotyear <- renderPlot({

    ggplot(filter(rain,format(rain$V1,format="%Y")==input$years),aes(x=V1,y=V2))+
      geom_line()+
      labs(x="日期", y="雨量") + thm() + 
      scale_x_date(labels=date_format("%m"), breaks = date_breaks("1 month"))

  })

})
