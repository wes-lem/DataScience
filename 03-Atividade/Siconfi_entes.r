# Siconfi - RREO

library(httr)
library(jsonlite)
library(stringr)
library(dplyr)
library(tidyr)
library(dplyr)
library(readr)

tipo_relatorio <- "entes"

#################################################################
## PARAMETRIZAÇÃO DE VARIÁVEIS - INÍCIO
#################################################################

nome_arq = "Entes.csv"

#################################################################
## PARAMETRIZAÇÃO DE VARIÁVEIS - FIM
#################################################################

base_url_rreo <- paste("http://apidatalake.tesouro.gov.br/ords/siconfi/tt/",tolower(tipo_relatorio),"?", sep = "")

# arq para coletar todas as urls dos extratos de entregas
arq<- c()

chamada_api_rreo <- paste(base_url_rreo, sep = "")
arq <- c(arq, chamada_api_rreo)

# criar variÃ¡veis do loop
extratos <- c()
extratos_urls<-c()
status_api<- c()
status_cod_ibge<- c()
p1 <- proc.time()
# loop em arq para baixar o extrato individual de cada ente

total_cons <- length(arq)
count <- 0

for (i in arq){
  # acessa o API e baixa o arquivo JSON  
  ext_api <- GET(i)
  
  if (status_code(ext_api) != 200){
    Sys.sleep(1)
    ext_api <- GET(i)
    
    if (status_code(ext_api) != 200){
      Sys.sleep(10)
      ext_api <- GET(i)}
    
  }
  
  ext_txt <- content(ext_api, as="text", encoding="UTF-8")
  
  ext_json <- fromJSON(ext_txt, flatten = FALSE)
  
  ext <- as.data.frame(ext_json[[1]])
  
  # juntar os extratos
  extratos<- rbind(ext, extratos)
  
  # verificar status da consulta
  status_api<- c(status_code(ext_api),status_api )
  
  count <- count + 1
  print(paste(toString(count), "of", toString(total_cons), sep = " "))
  
}
print(proc.time() - p1)


# Criar arquivo .csv
write_csv(extratos, nome_arq)
