library(httr)
library(jsonlite)
library(dplyr)
library(readr)

# Parâmetros
tipo_relatorio <- "rreo"
anexo <- "RREO-Anexo%2001"
periodicidade <- "B"  # Bimestral
anos <- 2025:2015
bimestres <- 1:6

# Códigos dos entes (estados + DF) 
entes <- c( 11:17, 21:29, 31:35, 41:43, 50:53 )

# URL base da API
base_url <- "http://apidatalake.tesouro.gov.br/ords/siconfi/tt/rreo?"

# Função de coleta
coletar_dados_rreo <- function() {
  dados_completos <- data.frame()
  total_cons <- length(entes) * length(anos) * length(bimestres)
  count <- 0
  
  for (ente in entes) {
    for (ano in anos) {
      for (bim in bimestres) {
        url <- paste0(base_url,
                      "an_exercicio=", ano,
                      "&nr_periodo=", bim,
                      "&co_tipo_demonstrativo=", periodicidade,
                      "&no_anexo=", anexo,
                      "&id_ente=", ente)
        
        tryCatch({
          resp <- GET(url)
          
          if (status_code(resp) == 200) {
            conteudo <- content(resp, as = "text", encoding = "UTF-8")
            dados_json <- fromJSON(conteudo, flatten = TRUE)
            
            if (length(dados_json$items) > 0) {
              dados_df <- as.data.frame(dados_json$items)
              dados_completos <- bind_rows(dados_completos, dados_df)
            }
          } else {
            warning(paste("Erro:", status_code(resp), "- Ente", ente, "Ano", ano, "Bim", bim))
          }
          
          count <- count + 1
          print(paste(count, "de", total_cons, "- Ente:", ente, "Ano:", ano, "Bim:", bim))
          Sys.sleep(0.5)
          
        }, error = function(e) {
          message(paste("Erro ao processar Ente", ente, "Ano", ano, "Bim", bim, ":", e$message))
        })
      }
    }
  }
  
  return(dados_completos)
}

# Executando a coleta
dados_rreo <- coletar_dados_rreo()

# Salvando os dados
write_csv(dados_rreo, "RREO_Anexo1_Estados_DF_2015-2025.csv")