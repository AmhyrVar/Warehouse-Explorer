library(tidyverse)

drugs_map <- read.csv("E:/OMOP Tools/Vocabulary/CONCEPT.csv")

write.csv(CONCEPT, file = "Concept.csv", na = "", row.names = FALSE)

concept_ancestor <- read.csv("C:/Voca/CONCEPT_ANCESTOR.csv")

write.csv(concept_ancestor, file = "CONCEPT_ANCESTOR.csv", na = "", row.names = FALSE)


concept_class <- read.csv("C:/Voca/CONCEPT_CLASS.csv")

write.csv(concept_class, file = "CONCEPT_CLASS.csv", na = "", row.names = FALSE)

###########ici
concept_synonym <- read.csv("C:/Voca/CONCEPT_CLASS.csv")

write.csv(concept_synonym, file = "CONCEPT_synonym.csv", na = "", row.names = FALSE)


VOCABULARY <- read.csv("C:/Voca/VOCABULARY.csv")

write.csv(VOCABULARY, file = "VOCABULARY.csv", na = "", row.names = FALSE)

############ clean de

drug_exp <- read.csv("actual/drug_exposure.csv")
drug_exp[drug_exp == "NA"] <- ""
write.csv(drug_exp, file = "actual/drug_exp.csv", na = "", row.names = FALSE)

########explore diff
ar1 <- read.csv("actual/achilles_results_ohdsi 1.csv")
ar2 <- read.csv("actual/achilles_results_ohdsi 2.csv")
library(tidyverse)

# Trouver les lignes uniques dans ar1
unique_in_ar1 <- anti_join(ar1, ar2, by = c("analysis_id", "stratum_1"))

# Trouver les lignes uniques dans ar2
unique_in_ar2 <- anti_join(ar2, ar1, by = c("analysis_id", "stratum_1"))

# Ajouter une colonne pour indiquer l'origine des données
unique_in_ar1$source <- "ar1"
unique_in_ar2$source <- "ar2"
