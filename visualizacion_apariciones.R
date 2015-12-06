rm(list=ls())

require(plyr)
require(jsonlite)
require(stringr)
require(stringi)

grupos <- c("providencia","de_bruces_a_mi", "tarmac")

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
    flatten_data <- lapply(setNames(mapas, names(mapas)), function(x) cbind2(x[[2]][[2]], x[[2]][[3]]))
    ldply(flatten_data, cbind)
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
str(flatten_data)

require(timelineR)
timeline()


format_data <- function(data) {
    len <- length(data)
    types <- c()
    for(i in 1:len) {
        types[i] <- switch(typeof(data[,i]), character="as.factor", logical="as.factor", integer="as.numeric","")
    }
    (expr <- paste0(types,"(data$",colnames(data),")"))
    for(i in 1:len){
        data[i] <- (eval(parse(text = expr[i])))
    }
    data
}

flatten_data <- format_data(flatten_data)
