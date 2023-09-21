library(httr)
library(rvest)
library(car)
library(stringr)
library(readr)
library(magrittr) 
library(dplyr)
library(jsonlite)


KOR_ticker = read.csv('C:/dongwoon.kang/00_Git/Crawling-stock-data/data/KOR_ticker.csv', row.names = 1)
print(KOR_ticker$'종목코드'[1])



























