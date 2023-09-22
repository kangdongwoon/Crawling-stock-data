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
  trdDd = biz_day,
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
  trdDd = biz_day,
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
          , row.names = T, fileEncoding = "cp949")
# write.csv(down_sector, 'C:/dongwoon.kang/00_Git/Crawling-stock-data/data/krx_sector.csv')
#########################################################################################################
# 개별종목 지표 OTP 발급
gen_otp_url =
  'http://data.krx.co.kr/comm/fileDn/GenerateOTP/generate.cmd'
gen_otp_data = list(
  searchType = '1',
  mktId = 'ALL',
  trdDd = biz_day, # 최근영업일로 변경
  csvxls_isNo = 'false',
  name = 'fileDown',
  url = 'dbms/MDC/STAT/standard/MDCSTAT03501'
)
otp = POST(gen_otp_url, query = gen_otp_data) %>%
  read_html() %>%
  html_text()

# 개별종목 지표 데이터 다운로드
down_url = 'http://data.krx.co.kr/comm/fileDn/download_csv/download.cmd'
down_ind = POST(down_url, query = list(code = otp),
                add_headers(referer = gen_otp_url)) %>%
  read_html(encoding = 'EUC-KR') %>%
  html_text() %>%
  read_csv()

# write.csv(down_ind, 'C:/dongwoon.kang/00_Git/Crawling-stock-data/data/krx_ind.csv')
write.csv(down_ind, 'C:/dongwoon.kang/00_Git/Crawling-stock-data/data/krx_ind.csv'
          , row.names = T, fileEncoding = "cp949")
#####################################################################

# First row is stringsAsFactors, because it is names of each column
down_sector = read.csv('C:/dongwoon.kang/00_Git/Crawling-stock-data/data/krx_sector.csv', row.names = 1,
                       stringsAsFactors = FALSE, fileEncoding = "cp949")
down_ind = read.csv('C:/dongwoon.kang/00_Git/Crawling-stock-data/data/krx_ind.csv',  row.names = 1,
                    stringsAsFactors = FALSE, fileEncoding = "cp949")


#same names of column
intersect(names(down_sector), names(down_ind))


#companies that are only in the sector or the ind
setdiff(down_sector[, '종목명'], down_ind[ ,'종목명'])


#combine the sector and the ind
KOR_ticker = merge(down_sector, down_ind,
                   by = intersect(names(down_sector), names(down_ind)),
                   all = FALSE) #FALSE = return intersection


# order by market capitalization
KOR_ticker = KOR_ticker[order(-KOR_ticker[, '시가총액']), ]
print(head(KOR_ticker))

KOR_ticker[grepl('스팩', KOR_ticker[, '종목명']), '종목명']  

#종목코드 끝이 0이 아닌 우선주: 보통주에 비해서 특정한 우선권을 부여한 주식
#str_sub will recycle all arguments to be the same length as the longest argument
KOR_ticker = KOR_ticker[!grepl('스팩', KOR_ticker[, '종목명']), ]


rownames(KOR_ticker) = NULL  #행 이름을 초기화
write.csv(KOR_ticker, 'C:/dongwoon.kang/00_Git/Crawling-stock-data/data/KOR_ticker.csv', fileEncoding = "cp949")

