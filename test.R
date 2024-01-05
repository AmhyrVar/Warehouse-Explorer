library(tidyverse)

de <- read.csv("actual/drug_exposure.csv")
write.csv(de, file = "actual/de_test.csv", na = "", row.names = FALSE)

mystuff <-  read.csv("drug_exposure/drug_exposure_mapped.csv")

drug_concept <- Concept %>% 
  filter(concept_class_id == "Drug")

#############################
install.packages("remotes")
remotes::install_github("OHDSI/Achilles")
install.packages("Andromeda")

library(Achilles)
library(DatabaseConnector)

dsn_database= "postgres"
dsn_hostname = "broadsea-atlasdb"
dsn_port="5432"
dsn_uid="postgres"
dsn_pwd="mypass"

# Configuration de la connexion
connectionDetails <- createConnectionDetails(
  dbms="postgresql", 
  server="broadsea-atlasdb/postgres",
  user="postgres", 
  password="mypass", 
  port="5432"
)

# L'ID du schéma CDM et le schéma où les résultats seront stockés
cdmDatabaseSchema <- "demo_cdm"
resultsDatabaseSchema <- "demo_cdm_results"

createIndices(connectionDetails = connectionDetails, 
              resultsDatabaseSchema = "demo_cdm_results", 
              outputFolder = "output")

# Créer les analyses Achilles
achilles(connectionDetails, 
         cdmDatabaseSchema = cdmDatabaseSchema, 
         resultsDatabaseSchema = resultsDatabaseSchema,
         
         cdmVersion = "5.3", 
         vocabDatabaseSchema = cdmDatabaseSchema,
         outputFolder = "./")


list <- listMissingAnalyses(connectionDetails, resultsDatabaseSchema)

details <- getAnalysisDetails()

a <- showReportTypes()


exportMetaToJson(connectionDetails,
                 cdmDatabaseSchema = "cdm4_sim",
                 outputPath = "/")



###########Quality

install.packages("remotes")
remotes::install_github("OHDSI/DataQualityDashboard")

cdmSourceName <- "OHDSI Eunomia Demo Database" # a human readable name for your CDM source
cdmVersion <- "5.3"
numThreads <- 1 # on Redshift, 3 seems to work well

# specify if you want to execute the queries or inspect them ------------------------------------------
sqlOnly <- FALSE
sqlOnlyIncrementalInsert <- FALSE # set to TRUE if you want the generated SQL queries to calculate DQD results and insert them into a database table (@resultsDatabaseSchema.@writeTableName)
sqlOnlyUnionCount <- 1 

jsonpath <- "./results.json"
outputFolder <- "./"
outputFile <- "results.json"
writeToCsv <- FALSE # set to FALSE if you want to skip writing to csv file
csvFile <- "report.csv"
checkLevels <- c("TABLE", "FIELD", "CONCEPT")
checkNames <- c()

DataQualityDashboard::executeDqChecks(connectionDetails = connectionDetails, 
                                      cdmDatabaseSchema = cdmDatabaseSchema, 
                                      resultsDatabaseSchema = resultsDatabaseSchema,
                                      cdmSourceName = cdmSourceName, 
                                      cdmVersion = cdmVersion,
                                      numThreads = numThreads,
                                      sqlOnly = FALSE, 
                                      sqlOnlyUnionCount = sqlOnlyUnionCount,
                                      sqlOnlyIncrementalInsert = sqlOnlyIncrementalInsert,
                                      outputFolder = outputFolder,
                                      outputFile = outputFile
                                      ,tablesToExclude = c("CONCEPT", "VOCABULARY", "CONCEPT_ANCESTOR",
                                                           "CONCEPT_RELATIONSHIP", "CONCEPT_CLASS", "CONCEPT_SYNONYM", "RELATIONSHIP", "DOMAIN"),
                                      
                                      writeToCsv = TRUE,
                                      csvFile = csvFile,
                                      checkLevels = checkLevels,
                                      checkNames = checkNames,
                                      verboseMode = TRUE,
                                      writeToTable = FALSE)


viewDqDashboard(jsonPath, launch.browser = NULL, display.mode = NULL, ...)

############Vocab
remotes::install_github("OHDSI/ETL-Synthea")

library(ETLSyntheaBuilder)
cdmSchema = cdmDatabaseSchema
vocabFileLoc = "./"
LoadVocabFromCsv(connectionDetails, cdmSchema, vocabFileLoc, bulkLoad = FALSE)


###########test 1930
library(tidyverse)
type()
class(person_mapped$year_of_birth)
class(1930)
class(person$year_of_birth[1])
person <- person_mapped %>% 
  mutate(year_of_birth = 1930)
write.csv(person, file = "person/person.csv", na = "", row.names = FALSE)
