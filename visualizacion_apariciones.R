rm(list=ls())

require(plyr)
require(jsonlite)
require(stringr)
require(stringi)
require(lubridate)

grupos <- c("esteman","laura_y_la_maquina_de_escribir", "pedrina_y_rio")

## Del repositorio son0p/mapasGrupos retorna los enlaces a los archivos geojson
get_raw_link <- function(github_repo, grupo) {
    paste0("https://raw.githubusercontent.com/",github_repo,"/master/",grupo,".geojson")
}

## Del repositorio son0p/mapasGrupos retorna los archivos geojson
get_raw_geojson <- function(github_repo, grupo) {
    tryCatch({
        geojson <- fromJSON(get_raw_link(github_repo,grupo))
        geojson
    }, error = function(e) {print("error")})
}

## Basado en la estructura del geojson toma las features y sus propiedades y los exporta como data.frame
## Acá solo cojo los datos de las features y no la geometría que contiene las coordenadas
flat_data <- function(mapas) {
    flatten_features <- lapply(setNames(mapas, names(mapas)), function(x) x[['features']][['properties']]) # Saco las features del mapa para cada grupo y la meto como un elemento de una lista
    flatten_geometry <- lapply(setNames(mapas, names(mapas)), function(x) x[['features']][['geometry']]['coordinates']) # Sacos las geometrías del mapa para cada grupo y la meto como un elemento de una lista
    flatten_features <- ldply(flatten_features, cbind) # Uno la lista de cada grupo en una sola
    flatten_geometry <- ldply(flatten_geometry, cbind)  # Uno la lista de cada grupo en una sola
    flatten_geometry <- data.frame(matrix(unlist(flatten_geometry$coordinates), nrow=length(flatten_geometry$coordinates), byrow=TRUE)) # La línea de arriba es sacada de acá http://www.r-bloggers.com/converting-a-list-to-a-data-frame/ Para convertir una lista en un data.frame
    colnames(flatten_geometry) <- c("x","y")
    cbind2(flatten_features, flatten_geometry) # Combino las features con las geometrías de cada grupo (solo soporta puntos)
}

open_in_excel <- function(some_df){
    tFile<-tempfile(fileext=paste0(substitute(some_df), ".csv"),tmpdir="/tmp")
    write.csv2(some_df, tFile)
    system(paste('libreoffice ', tFile, '&'))
}

normalizarNombre <- function(nombre) {
    nombre <- str_replace_all(nombre,"X","")
    nombre <- str_replace_all(nombre,"[[:punct:]]"," ")
    nombre <- stri_trans_general(nombre, "Any-Title")
    nombre <- str_replace_all(nombre,"\\s","")
    nombre <- stri_trans_general(nombre, "latin-ascii")
    nombre
}

mapas <- lapply(setNames(grupos, grupos), function(x) get_raw_geojson("son0p/mapasGrupos",x))

get_raw_link("son0p/mapasGrupos", grupos)

flatten_data <- flat_data(mapas)
colnames(flatten_data) <- normalizarNombre(colnames(flatten_data))
str(flatten_data) # Sacar los datos de las coordenadas

open_in_excel(flatten_data)

flatten_data <- flatten_data[-which(is.na(flatten_data$Date)),] # Se retira donde no hay fecha
flatten_data$Date <- ymd(flatten_data$Date)
flatten_data$Capacity <- as.numeric(flatten_data$Capacity)
devtools::install_github("hrbrmstr/streamgraph")
require(streamgraph)
streamgraph(flatten_data, "Id", "Capacity" , "Date", interactive = TRUE , interpolate="step", offset = "zero") %>%  sg_legend(show=TRUE, label="Agrupación: ") %>% sg_axis_x(20, "año", "%Y")
