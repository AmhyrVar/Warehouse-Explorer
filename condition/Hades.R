install.packages("remotes")
remotes::install_github("OHDSI/Achilles")
install.packages("Andromeda")
install.packages("RPostgreSQL")

library(Achilles)
library(DatabaseConnector)
library(DBI)



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







############Vocab
remotes::install_github("OHDSI/ETL-Synthea")

library(ETLSyntheaBuilder)
cdmSchema = cdmDatabaseSchema
vocabFileLoc = "./"

LoadVocabFromCsv(connectionDetails, cdmSchema, vocabFileLoc, bulkLoad = FALSE)
#####tables
syntheaFileLoc = vocabFileLoc 
syntheaSchema = cdmSchema

LoadSyntheaTables(
  connectionDetails,
  syntheaSchema,
  syntheaFileLoc,
  bulkLoad = FALSE
)



CreateSyntheaTables(connectionDetails, syntheaSchema, syntheaVersion = "2.7.0")
