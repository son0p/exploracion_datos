rm(list=ls())

require(RCurl)
require(XML)
require(stringr)
require(stringi)

##################################################################################
## require(devtools)                                                             #
## install_github("christophergandrud/dpmr")                                     #
require(dpmr) ## https://github.com/christophergandrud/dpmr/                     #
URL <- "https://github.com/son0p/dataSet_grupos_casa_teatro/archive/master.zip"  #
gdp_data <- datapackage_install(path = URL)                                      #
str(gdp_data)                                                                    #
###############  No funciona tan bien el paquete de R ############################


## Lectura del datapackage data
direccion <- "https://raw.githubusercontent.com/son0p/dataSet_grupos_casa_teatro/master/data/Artistas_casa_teatro_filtrado.csv"
url_direccion<- getURL(direccion)
data <- read.csv(text = url_direccion)
data
