rm(list=ls())

require(RCurl)
require(jsonlite)
require(plyr)
require(dplyr)
require(stringr)
library(datacomb)

##################################################################################
## require(devtools)                                                             #
## install_github("christophergandrud/dpmr")                                     #
require(dpmr) ## https://github.com/christophergandrud/dpmr/                     #
URL <- "https://github.com/son0p/dataSet_grupos_casa_teatro/archive/master.zip"  #
gdp_data <- datapackage_install(path = URL)                                      #
str(gdp_data)                                                                    #
###############  No funciona tan bien el paquete de R ############################

raw_datapackage <- function(github_repo) {
    tryCatch({
    datapackage <- fromJSON(paste0("https://raw.githubusercontent.com/",github_repo,"/master/datapackage.json"))
    datapackage$resources$path <- paste0("https://raw.githubusercontent.com/",github_repo,"/master/",datapackage$resources$path)
    datapackage
}, error = function(e) {print("error")})
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

## Obtener los fields
lista_datapackages[[1]]$resources$schema[[1]]
datos <- datos_datapackage[[1]]
colnames(datos)[1] <- "nombre"
Datacomb(datos)


data(diamonds, package="ggplot2")
str(diamonds)
Datacomb(diamonds)

library(tau)
txt <- as.character(datos$Descripción[43])
## incremental
     textcnt(txt, method = "string", persistent = TRUE, n = 1L)
     textcnt(txt, method = "string", n = 2L)

str(datos_datapackage[[1]])

## Installing https://github.com/trinker/qdap Quantitative Discourse Analysis Package using pacman
if (!require("pacman")) install.packages("pacman")
pacman::p_load_gh(
    "trinker/qdapDictionaries",
    "trinker/qdapRegex",
    "trinker/qdapTools",
    "trinker/qdap"
)

## Installing https://github.com/trinker/discon discon is a collection of R tools to enhance analysis of discourse connectors in text. using pacman
if (!require("pacman")) install.packages("pacman")
pacman::p_load_gh(
    "trinker/qdapRegex",
    "trinker/qdapTools",
    "trinker/qdapDictionaries",
    "trinker/qdap",
    "trinker/discon"
    )

txt <- check_text(datos$Descripción)
?any

## RTextTools
## http://www.rtexttools.com/documentation.html
## http://journal.r-project.org/archive/2013-1/collingwood-jurka-boydstun-etal.pdf
install.packages("RTextTools")

require(RTextTools)
data(USCongress)
doc_matrix <- create_matrix(USCongress$text, language = "english", removeNumbers = TRUE, stemWords = TRUE, removeSparseTerms = 0.998)

str(doc_matrix)

library(RTextTools)
data(NYTimes)
data <- NYTimes[sample(1:3100,size=100,replace=FALSE),]
matrix <- create_matrix(cbind(data["Title"],data["Subject"]), language="english", removeNumbers=TRUE, stemWords=FALSE, weighting=tm::weightTfIdf)
container <- create_container(matrix,data$Topic.Code,trainSize=1:75, testSize=76:100, virgin=FALSE)
models <- train_models(container, algorithms=c("MAXENT","SVM"))
results <- classify_models(container, models)
score_summary <- create_scoreSummary(container, results)

analytics <- create_analytics(container, results)
summary(analytics)

# AUTHOR: Tim Jurka
# DESCRIPTION: This file demonstrates saving a trained model and using it to classify new data.

# LOAD THE RTextTools LIBARY
library(RTextTools)

# READ THE CSV DATA
data(NYTimes)


# [OPTIONAL] SUBSET YOUR DATA TO GET A RANDOM SAMPLE
NYTimes <- NYTimes[sample(1:3000,size=3000,replace=FALSE),]


# CREATE A TERM-DOCUMENT MATRIX THAT REPRESENTS WORD FREQUENCIES IN EACH DOCUMENT
# WE WILL TRAIN ON THE Title and Subject COLUMNS
matrix <- create_matrix(cbind(NYTimes["Title"],NYTimes["Subject"]), language="english", removeNumbers=TRUE, stemWords=TRUE, weighting=weightTfIdf)

# CREATE A container THAT IS SPLIT INTO A TRAINING SET AND A TESTING SET
# WE WILL BE USING Topic.Code AS THE CODE COLUMN. WE DEFINE A 2000
# ARTICLE TRAINING SET AND A 1000 ARTICLE TESTING SET.
container <- create_container(matrix,NYTimes$Topic.Code,trainSize=1:3000,virgin=FALSE)


# THERE ARE TWO METHODS OF TRAINING AND CLASSIFYING DATA.
# ONE WAY IS TO DO THEM AS A BATCH (SEVERAL ALGORITHMS AT ONCE)
models <- train_models(container, algorithms=c("SVM","MAXENT"))

# NOW SAVE THE ORIGINAL TERM-DOCUMENT MATRIX AND THE TRAINED MODELS
save(matrix,file="originalMatrix.Rd")
save(models,file="trainedModels.Rd")
rm(list=c("data","matrix","container","models")) # DELETE THE OLD DATA NOW THAT IT'S SAVED


# CLASSIFYING USING THE TRAINED MODELS
# READ THE CSV DATA
library(RTextTools)
data(NYTimes)


# [OPTIONAL] SUBSET YOUR DATA TO GET A RANDOM SAMPLE
NYTimes <- NYTimes[sample(3000:3100,size=100,replace=FALSE),]
load("originalMatrix.Rd")
load("trainedModels.Rd")

# CREATE A TERM-DOCUMENT MATRIX THAT REPRESENTS WORD FREQUENCIES IN EACH DOCUMENT
# WE WILL TRAIN ON THE Title and Subject COLUMNS
new_matrix <- create_matrix(cbind(NYTimes["Title"],NYTimes["Subject"]), language="english", removeNumbers=TRUE, stemWords=TRUE, weighting=weightTfIdf, originalMatrix=matrix)

# CREATE A container THAT IS SPLIT INTO A TRAINING SET AND A TESTING SET
# WE WILL BE USING Topic.Code AS THE CODE COLUMN. WE DEFINE A 2000
# ARTICLE TRAINING SET AND A 1000 ARTICLE TESTING SET.
container <- create_container(new_matrix,NYTimes$Topic.Code,testSize=1:100,virgin=FALSE)

results <- classify_models(container, models)


# VIEW THE RESULTS BY CREATING ANALYTICS
# IF YOU USED OPTION 1, YOU CAN GENERATE ANALYTICS USING
analytics <- create_analytics(container, results)

# RESULTS WILL BE REPORTED BACK IN THE analytics VARIABLE.
# analytics@algorithm_summary: SUMMARY OF PRECISION, RECALL, F-SCORES, AND ACCURACY SORTED BY TOPIC CODE FOR EACH ALGORITHM
# analytics@label_summary: SUMMARY OF LABEL (e.g. TOPIC) ACCURACY
# analytics@document_summary: RAW SUMMARY OF ALL DATA AND SCORING
# analytics@ensemble_summary: SUMMARY OF ENSEMBLE PRECISION/COVERAGE. USES THE n VARIABLE PASSED INTO create_analytics()

head(analytics@algorithm_summary)
head(analytics@label_summary)
head(analytics@document_summary)
head(analytics@ensemble_summary)

# WRITE OUT THE DATA TO A CSV
write.csv(analytics@algorithm_summary,"SampleData_AlgorithmSummary.csv")
write.csv(analytics@label_summary,"SampleData_LabelSummary.csv")
write.csv(analytics@document_summary,"SampleData_DocumentSummary.csv")
write.csv(analytics@ensemble_summary,"SampleData_EnsembleSummary.csv")
