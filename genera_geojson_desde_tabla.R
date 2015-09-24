rm(list=ls())

## require(devtools)
## install_github("christophergandrud/dpmr")
require(dpmr) ## https://github.com/christophergandrud/dpmr/
URL <- "https://github.com/son0p/dataSet_grupos_casa_teatro/archive/master.zip"
gdp_data <- datapackage_install(path = URL)
str(gdp_data)
###  No funciona tan bien el paquete de R ###

require(RCurl)
require(XML)
require(stringr)
require(stringi)
direccion <- "https://raw.githubusercontent.com/son0p/dataSet_grupos_casa_teatro/master/data/Artistas_casa_teatro_filtrado.csv"
url_direccion<- getURL(direccion)
data <- read.csv(text = url_direccion)

## El dato de la coordenada viene en el campo geometry pero viene en formato xml dentro de Point > coordinates, se usa el siguiente patrón para quitar lo que sobra y dejar solo latitud y longitud al extraérselo como texto
pattern <- "-.[0-9].[0-9]+,[0-9].[0-9]+"
data$geometry <- str_extract(data$geometry, pattern)
data

plantilla <-  '{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {
        "origen": "nombre"
      },
      "geometry": {
        "type": "Point",
        "coordinates": [
          coordenada
        ]
      }
    }
  ]
}'

plantilla <- str_replace(plantilla,"nombre",data$name)
plantilla <- str_replace(plantilla,"coordenada",data$geometry)

normalizarNombre <- function(nombre) {
    nombre <- str_replace_all(nombre,"X","")
    nombre <- str_replace_all(nombre,"[[:punct:]]"," ")
    nombre <- stri_trans_general(nombre, "Any-Title")
    nombre <- str_replace_all(nombre,"\\s","")
    nombre <- stri_trans_general(nombre, "latin-ascii")
    nombre
}


for(i in 1:length(plantilla)) {
    nombre <- normalizarNombre(data$name[i])
    cat(plantilla[i], file = paste0("mapasGrupos/",nombre,".geojson"))
}

## Para poder editar con geojson.io mirar con detenimiento https://github.com/JasonSanford/gitspatial para hacer consultas sobre esos datos
