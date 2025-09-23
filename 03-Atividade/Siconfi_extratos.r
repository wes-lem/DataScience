# Siconfi - Extrato de entregas

library(httr)
library(jsonlite)
library(stringr)
library(dplyr)
library(tidyr)
library(dplyr)
library(readr)

tipo_relatorio <- "extrato_entregas"

#################################################################
## PARAMETRIZAÇÃO DE VARIÁVEIS - INÍCIO
#################################################################

#entes <- c(11:17, 21:29, 31:35, 41:43, 50:53) # Todas as UFs

# Carrega os códigos dos entes listados no arquivo "Entes.csv"
aux_entes <- read.csv(file = 'Entes.csv')
aux_entes_filtrado <- subset(aux_entes, esfera == "E" | esfera == "D")
entes <- aux_entes_filtrado$cod_ibge

anos <- 2025:2015

#################################################################
## PARAMETRIZAÇÃO DE VARIÁVEIS - FIM
#################################################################

base_url_rreo <- paste("http://apidatalake.tesouro.gov.br/ords/siconfi/tt/",tolower(tipo_relatorio),"?", sep = "")

# arq para coletar todas as urls dos extratos de entregas
arq<- c()

# loop para montar as urls
for (y in anos){
  # loop por todos os entes (cod_ibge) da tabela entes para acessar API, baixar arquivo e variável com todos as urls
  for (e in entes){
        chamada_api_rreo <- paste(base_url_rreo,
                                  "id_ente=", toString(e), "&",
                                  "an_referencia=", toString(y), sep = "")
        
        arq <- c(arq, chamada_api_rreo)
  }
}
# criar data frame com ente, cod_ibge e url
# arq_ente<- data.frame ( "ente" =  entes_knit$ente, "cod_ibge" = entes_knit$cod_ibge, "url_extrato"=arq  )


# criar variáveis do loop
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
  
  # verificar se acessou corretamente a API
  # status_cod_ibge<- c(status_cod_ibge, ext_json[["items"]][["cod_ibge"]])
  count <- count + 1
  print(paste(toString(count), "of", toString(total_cons), sep = " "))
  
}
print(proc.time() - p1)

# Criar arquivo .csv
write_csv(extratos,"Siconfi_Extratos_15-25_UFs.csv")