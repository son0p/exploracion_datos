rm(list=ls())

require(RCurl)
require(jsonlite)
require(plyr)
require(dplyr)
require(stringr)

##################################################################################
## require(devtools)                                                             #
## install_github("christophergandrud/dpmr")                                     #
require(dpmr) ## https://github.com/christophergandrud/dpmr/                     #
URL <- "https://github.com/son0p/dataSet_grupos_casa_teatro/archive/master.zip"  #
gdp_data <- datapackage_install(path = URL)                                      #
str(gdp_data)                                                                    #
###############  No funciona tan bien el paquete de R ############################

raw_datapackage <- function(github_repo) {
    datapackage <- fromJSON(paste0("https://raw.githubusercontent.com/",github_repo,"/master/datapackage.json"))
    datapackage$resources$path <- paste0("https://raw.githubusercontent.com/",github_repo,"/master/",datapackage$resources$path)
    datapackage
}

get_data_datapackage <- function(path) {
    print(path)
    urls <- getURL(path)
    data <- read.csv(text = urls)
    data
}

## Los datapackages de agrupaciones musicales los estamos recolectando en https://github.com/son0p/exploracion_datos/blob/master/datapackages.md

## Repositorios con datos
repos <- c("son0p/dataSet_grupos_casa_teatro","son0p/dataSets_grupos_medellin","son0p/dataSet_grupos_casa_estrategias")
repos_names <- str_replace(repos, "(\\w+/)(.*)","\\2")

## Se obtiene cada datapackage y se modifican las url para acceder directamente a los datos
lista_datapackages <- lapply(setNames(repos, repos_names),raw_datapackage)
## Se obtienen los path de cada datapackage
paths <- lapply(lista_datapackages, function(x) x$resources$path)
## Se obtiene los datos en cada datapackage
datos_datapackage <- lapply(paths, function(x) get_data_datapackage(x))

lista_datapackages[[1]]
