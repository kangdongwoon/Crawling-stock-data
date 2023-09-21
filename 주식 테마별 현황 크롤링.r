library(httr)
library(rvest)
library(car)
library(stringr)
library(readr)
library(magrittr) 
library(dplyr)

### Day before 2 workingdays
url = 'https://finance.naver.com/sise/sise_deposit.nhn'

biz_day = GET(url) %>%
  read_html(encoding = 'EUC-KR') %>%
  html_nodes(xpath =
               '//*[@id="type_1"]/div/ul[2]/li/span') %>%
  html_text() %>%
  str_match(('[0-9]+.[0-9]+.[0-9]+') ) %>%
  str_replace_all('\\.', '')

gen_otp_url =
  'http://data.krx.co.kr/comm/fileDn/GenerateOTP/generate.cmd'
##### Kospi #####
gen_otp_data = list(
  mktId = 'STK',
  trdDd = '20210108',
  money = '1',
  csvxls_isNo = 'false',
  name = 'fileDown',
  url = 'dbms/MDC/STAT/standard/MDCSTAT03901'
)
otp = POST(gen_otp_url, query = gen_otp_data) %>%
  read_html() %>%
  html_text()

down_url = 'http://data.krx.co.kr/comm/fileDn/download_csv/download.cmd'
down_sector_KS = POST(down_url, query = list(code = otp),
                      add_headers(referer = gen_otp_url)) %>%
  read_html(encoding = 'EUC-KR') %>%
  html_text() %>%
  read_csv()

##### Kosdaq #####
gen_otp_data = list(
  mktId = 'KSQ', 
  trdDd = '20210108',
  money = '1',
  csvxls_isNo = 'false',
  name = 'fileDown',
  url = 'dbms/MDC/STAT/standard/MDCSTAT03901'
)
otp = POST(gen_otp_url, query = gen_otp_data) %>%
  read_html() %>%
  html_text()

down_sector_KQ = POST(down_url, query = list(code = otp),
                      add_headers(referer = gen_otp_url)) %>%
  read_html(encoding = 'EUC-KR') %>%
  html_text() %>%
  read_csv()

down_sector = rbind(down_sector_KS, down_sector_KQ)

#generate csv
ifelse(dir.exists('data'), FALSE, dir.create('data'))
write.csv(down_sector, 'C:/dongwoon.kang/00_Git/Crawling-stock-data/data/krx_sector.csv'
          , row.names = F, fileEncoding = "cp949")

