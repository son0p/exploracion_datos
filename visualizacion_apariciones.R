rm(list=ls())

require(plyr)
require(jsonlite)

library(datacomb)

grupos <- c("providencia","de_bruces_a_mi", "tarmac")

fromJSON("https://raw.githubusercontent.com/son0p/mapasGrupos/master/athemesis.geojson")

get_raw_link <- function(github_repo, grupo) {
    paste0("https://raw.githubusercontent.com/",github_repo,"/master/",grupo,".geojson")
}

get_raw_geojson <- function(github_repo, grupo) {
    tryCatch({
        geojson <- fromJSON(paste0("https://raw.githubusercontent.com/",github_repo,"/master/",grupo,".geojson"))
        geojson
    }, error = function(e) {print("error")})
}

mapas <- lapply(setNames(grupos, grupos), function(x) get_raw_geojson("son0p/mapasGrupos",x))

get_raw_link("son0p/mapasGrupos", grupos)

flat_data <- function(mapa) {
    features <- mapas[[1]][[2]]
    print((features))
    ##cbind(names(features), features)
}

flatten_data <- lapply(setNames(mapas, names(mapas)), flat_data)

cbind

names(mapas)

names(mapas[1])
cbind(names(mapas[1]),mapas[1]$providencia$features)
cbind(names(mapas[2]),mapas[2]$providencia$features)
cbind(names(mapas[2]),mapas[2]$providencia$features)

str(mapas$tarmac$features)
