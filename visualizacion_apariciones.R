rm(list=ls())

require(plyr)
require(jsonlite)
require(stringr)
require(stringi)
require(lubridate)
require(ggplot2)

grupos <- c("esteman","laura_y_la_maquina_de_escribir", "pedrina_y_rio","manuel_medrano", "fonseca")

source("utils.R")

mapas <- lapply(setNames(grupos, grupos), function(x) get_raw_geojson("son0p/mapasGrupos",x))

get_raw_link("son0p/mapasGrupos", grupos)

flatten_data <- flat_data(mapas)
colnames(flatten_data) <- normalizarNombre(colnames(flatten_data))
str(flatten_data) # Sacar los datos de las coordenadas

##open_in_excel(flatten_data)

##flatten_data <- flatten_data[-which(is.na(flatten_data$Date)),] # Se retira donde no hay fech
flatten_data <- flatten_data %>% dplyr::filter(Date > "2014-01-01")
flatten_data$Date <- ymd(flatten_data$Date)
flatten_data$Capacity <- as.numeric(flatten_data$Capacity)

#devtools::install_github("hrbrmstr/streamgraph")
require(streamgraph)
streamgraph(flatten_data, "Id", "Capacity" , "Date", interactive = TRUE , interpolate="step", offset = "zero") %>%  sg_legend(show=TRUE, label="Agrupación: ") %>% sg_axis_x(20, "año", "%Y")

## Usando https://plot.ly/r/
#devtools::install_github("ropensci/plotly") ## Descomentar esta línea para comentar
require(plotly)

b <- ggplot(flatten_data, aes(x = ymd(Date), y = as.numeric(Capacity), size = Capacity, colour = Id)) + geom_point(stat = "identity") + xlab("Fecha") + ylab("Capacidad") + labs(title = "Apariciones de Laura y la Máquina de Escribir y artistas similares")
(gg <- ggplotly(b))

# Indicador - Si relacionamos los tamaños de los sitios donde se presenta y la frecuencia de las presentaciones en un período determinado obtenemos una curva que nos permite evaluar la manera como se está desarrollando el proyecto en el tiempo

fonseca <- flatten_data %>% dplyr::filter(Id == "fonseca")
b <- ggplot(fonseca, aes(x = ymd(Date), y = as.numeric(Capacity))) + geom_smooth(method = "loess", formula = y ~ x, span = 0.4) + geom_point() + xlab("Fecha") + ylab("Capacidad") + labs(title = "Apariciones")
b

laura <- flatten_data %>% dplyr::filter(Id == "laura_y_la_maquina_de_escribir", Date > 2011)
b <- ggplot(laura, aes(x = ymd(Date), y = as.numeric(Capacity))) + geom_smooth(method = "loess", formula = y ~ x, span = 0.4) + geom_point() + xlab("Fecha") + ylab("Capacidad") + labs(title = "Apariciones")
b

b <- ggplot(flatten_data, aes(x = ymd(Date), y = as.numeric(Capacity))) + geom_smooth(method = "loess", formula = y ~ x, span = 0.4) + geom_point() + xlab("Fecha") + ylab("Capacidad") + labs(title = "Apariciones") + facet_wrap("Id")
b
(gg <- ggplotly(b)) ## No me funciona el smooth para ggplotly
