library(httr)
library(rvest)
library(car)
library(stringr)
library(readr)
library(magrittr) 
library(dplyr)
library(jsonlite)
library(xts)
library(lubridate)
library(timetk)

KOR_ticker = read.csv('C:/dongwoon.kang/00_Git/Crawling-stock-data/data/KOR_ticker.csv', row.names = 1,
                      fileEncoding = "cp949")
print(KOR_ticker$'종목코드'[1])
KOR_ticker$'종목코드' =
  str_pad(KOR_ticker$'종목코드', 6, side = c('left'), pad = '0')
ifelse(dir.exists('C:/dongwoon.kang/00_Git/Crawling-stock-data/data/KOR_price'), FALSE,
       dir.create('C:/dongwoon.kang/00_Git/Crawling-stock-data/data/KOR_price'))

i = 1
name = KOR_ticker$'종목코드'[i]

price = xts(NA, order.by = Sys.Date())

from = (Sys.Date() - years(3)) %>% str_remove_all('-')
to = Sys.Date() %>% str_remove_all('-')

url = paste0('https://fchart.stock.naver.com/siseJson.nhn?symbol=', name,
             '&requestType=1&startTime=', from, '&endTime=', to, '&timeframe=day')

data = GET(url)
data_html = data %>% read_html %>%
  html_text() %>%
  read_csv()

print(data_html)

price = data_html[c(1, 5)]
colnames(price) = (c('Date', 'Price'))
price = na.omit(price)
price$Date = parse_number(price$Date)
price$Date = ymd(price$Date)
price = tk_xts(price, date_var = Date)

print(tail(price))

write.csv(data.frame(price),
          paste0('C:/dongwoon.kang/00_Git/Crawling-stock-data/data/KOR_price/', name, '_price.csv'))















