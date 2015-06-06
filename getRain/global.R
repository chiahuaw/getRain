# from:http://shiny.rstudio.com/gallery/unicode-characters.html
# Cairo包的PNG设备似乎无法显示中文字符，强制使用R自身的png()设备
options(shiny.usecairo = FALSE)

# 请忽略以下代码，它只是为了解决ShinyApps上没有中文字体的问题
font_home <- function(path = '') file.path('~', '.fonts', path)
if (Sys.info()[['sysname']] == 'Linux' &&
      system('locate wqy-zenhei.ttc') != 0 &&
      !file.exists(font_home('wqy-zenhei.ttc'))) {
  if (!file.exists('wqy-zenhei.ttc'))
    shiny:::download(
      'https://github.com/rstudio/shiny-examples/releases/download/v0.10.1/wqy-zenhei.ttc',
      'wqy-zenhei.ttc'
    )
  dir.create(font_home())
  file.copy('wqy-zenhei.ttc', font_home())
  system2('fc-cache', paste('-f', font_home()))
}
rm(font_home)

#自訂函數，輪入年份如2015，抓取金門縣的日雨量並輸出matrix
getrain<-function(x) {
  url_list <- list()
  url_list <- paste('http://www.cwb.gov.tw/V7/climate/dailyPrecipitation/Data/467110_',x,'.htm',sep='')
  url_list <- unlist(url_list)
  get_url <- getURL(url_list,encoding = "UTF-8")
  get_url_parse <- htmlParse(get_url, encoding = "UTF-8")
  tablehead <- xpathSApply(get_url_parse, "//table[@class='Form00']/tr/td", xmlValue)
  Temp_Total <- matrix(tablehead, ncol = 12, byrow = TRUE)
  
  #紀錄向中央氣象局網頁存取的紀錄，藉以控制存取次數。
  weblog<-as.list(read.table("weblog.txt",encoding="UTF-8"))
  weblog<-as.list(c(weblog,as.character(Sys.time())))
  write.table(weblog,file="weblog.txt",fileEncoding="UTF-8",row.names=FALSE,col.names=FALSE)
  
  temp <- matrix(ncol = 2,nrow=384)
  temp[,2]<-matrix(Temp_Total,ncol=1)
  
  Temp1<-matrix(1:12,ncol=1,nrow=384)
  Temp1<-Temp1[order(Temp1[,1])]
  Temp2<-matrix(1:32,ncol=1,nrow=384)
  temp[,1]<- paste(year,"-",Temp1,"-",Temp2,sep="")
  
  for (i in 12:1) {
    temp<-temp[-(i*32),]
  }
  #修改空白值、"-"、"T"
  temp[temp[,2]=="-",2]<-0
  temp[temp[,2]=="T",2]<-0.05
  temp[temp[,2]=="",2]<-0.0001 #把未發生的日期的資料，填入0.0001
  temp<-as.data.frame(temp)
  temp$V1<-as.Date(temp[,1])
  temp$V2<-as.numeric(as.character((temp[,2])))
  temp<-temp[is.na(temp[,1])==F,]
  
  return(temp)
}


#載入既有資料
year<-format(Sys.Date(),format="%Y")
rm(dat)
dat<-data.frame()

for (y in 2006:(as.numeric(year)-1)) {
  path<-paste("data/",y,"_rain.csv",sep="")
  f<-file(path)
  a<-read.csv(f)
  
  #檢查前一年資料的更新狀況
  if ( y==(as.numeric(year)-1)) {
    if (grepl(0.0001,dat[nrow(a),2])==TRUE) {
      a<-getrain(year-1)
    }
  }
  
  dat<-rbind(dat,a)
  
  
}

dat[,1]<-as.Date(dat[,1])
dat[,2]<-as.numeric(as.character(dat[,2]))

#檢查year的資料在不在，在的話，載入，並檢查資料更新狀況。
if (system(paste("ls data/",year,"_rain.csv",sep=""))==0) {
  path<-paste("data/",year,"_rain.csv",sep="")
  f<-file(path)
  rain<-read.csv(f)
  #rain<-rain[,-1]
  if (grepl(0.0001,rain[as.character(rain$V1)==(Sys.Date()-1),2])==TRUE) {
   rain<-getrain(year) 
  }
  rain[,1]<-as.Date(rain[,1])
  rain[,2]<-as.numeric(as.character(rain[,2]))
}

if (system(paste("ls data/",year,"_rain.csv",sep=""))==1) {
  if (format(Sys.Date(),format="%m-%d")=="01-01") {
    rain<-c(0,0)
  }
  else { rain<-getrain(year) }
}

#存檔
path<-paste("data/",year,"_rain.csv",sep="")
write.csv(rain,file = path ,fileEncoding="UTF-8",row.names=FALSE)
