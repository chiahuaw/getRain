

library(shiny)
library(dplyr)
weblog<-as.list(read.table("weblog.txt",encoding="UTF-8"))
shinyUI(navbarPage("金門縣歷史日雨量查詢",
                   tabPanel("單年雨量",
                            titlePanel("單年度日雨量"),
                            selectInput("years",
                                        "年度",
                                        choices=c(unique(format(dat$V1,format="%Y")),unique(format(rain$V1,format="%Y"))),#(c("2006","2007","2008","2009","2010","2011","2012","2013","2014","2015")),
                                        selected="2015"),
                            selectInput("month",
                                        "月份",
                                        choices=c(paste(0,seq(1:9),sep=""),"10","11","12"),
                                        selected="1"),
                            downloadButton('downloadData', '下載單年雨量CSV檔'), #下載單年雨量CSV
                            navlistPanel("圖表類別",
                                         tabPanel("全年日雨量線圖",plotOutput("plot1")),
                                         tabPanel("單月日雨量線圖",plotOutput("plot2")),
                                         tabPanel("雨量表",dataTableOutput(outputId="table"))
                                        ),
                            
                            print(paste("資料更新時間：",last(weblog),",",length(weblog))) #監控對中央氣象局的存取次數
                            )
                   )
        )