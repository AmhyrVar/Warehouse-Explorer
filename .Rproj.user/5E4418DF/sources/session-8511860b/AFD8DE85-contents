library(tidyverse)
c <-read.csv("icu/inputevents.csv")
b <-read.csv("icu/outputevents.csv")
CONCEPT <- read_delim("Voca/CONCEPT.csv", delim = "\t", escape_double = FALSE, trim_ws = TRUE)


target_string <- "1127078"




rows_with_string <- apply(CONCEPT, 1, function(row) any(grepl(target_string, row)))


target_dataframe <- CONCEPT[rows_with_string, ]
target_concept <- CONCEPT[rows_with_string, ]

rows_with_string <- apply(pharmacy, 1, function(row) any(grepl(target_string, row)))


aspirine_pharmacy <- pharmacy[rows_with_string, ]


unique_values <- unique(pharmacy$medication)
print(unique_values)


#pour pharmacy prendre que les domain_id Drug


##################################################On commence ici##########################################"

#Créer un drug_exposure_temp 
drug_exposure_temp <- drug_exposure[FALSE, ]

# Afficher le nouveau dataframe
print(drug_exposure_temp)

#ça sera ma target à fill
#####################################################################

#####Transformer les colonnes de pharmacy#####

#choisir les colonnes à garder

pharmacy_selected <- pharmacy[, c("subject_id", "hadm_id", "pharmacy_id", "starttime", "stoptime", "medication")]
pharmacy_clean <- na.omit(pharmacy_selected)
#subject_id on la garde
#hadm_id on le garde
#pharmacy_id on le garde


pharmacy_clean1 <- pharmacy_clean
#starttime doit être modifié

pharmacy_clean1$starttime <- as.character(pharmacy_clean1$starttime)

# Convertir la colonne starttime au format de date souhaité
pharmacy_clean1$starttime <- as.Date(pharmacy_clean1$starttime)

#pharmacy_stoptime
pharmacy_clean1$stoptime <- as.character(pharmacy_clean1$stoptime)

pharmacy_clean1$stoptime <- as.Date(pharmacy_clean1$stoptime)

#avoir le type de données dans la colonne drug_exposure_start_date de drug_exposure TODO

#travail sur medication
pharmacy_clean1 <- pharmacy_clean1[!pharmacy_clean1$medication %in% c(1, 2), ]

unique_medication <- unique(pharmacy_clean1$medication)

# Créer un nouveau dataframe avec ces valeurs uniques
unique_medication_df <- data.frame(medication = unique_medication)
write.csv(unique_medication_df, file = "unique_medication")
#on fait les mapping sur usagi 

#faire le mapping

CONCEPT_drug_only <- CONCEPT[CONCEPT$domain_id == "Drug", ]

medication_map <- read_csv("medication_map.csv")
final_medication_map <- medication_map[, c("source_code_description", "target_concept_id")]

pharmacy_clean2 <- pharmacy_clean1 %>%
  left_join(final_medication_map, by = c("medication" = "source_code_description")) %>%
  # Selecting necessary columns and renaming the target_concept_id to medication
  select(-medication, medication = target_concept_id)

#remplir le df drug exposure
print(names(drug_exposure_temp))

if(nrow(drug_exposure_temp) == 0) {
  drug_exposure_temp <- drug_exposure_temp[seq_len(nrow(pharmacy_clean2)), ]
}

drug_exposure_temp$person_id <- pharmacy_clean2$subject_id
drug_exposure_temp$visit_occurrence_id <- pharmacy_clean2$hadm_id
drug_exposure_temp$drug_exposure_id <- pharmacy_clean2$pharmacy_id
drug_exposure_temp$drug_exposure_start_date <- pharmacy_clean2$starttime
drug_exposure_temp$drug_exposure_end_date <- pharmacy_clean2$stoptime
drug_exposure_temp$drug_source_concept_id <- pharmacy_clean2$medication


drug_exposure_temp <- drug_exposure_temp %>%
  mutate(drug_exposure_start_datetime = drug_exposure_start_date) %>% 
  mutate(drug_exposure_end_datetime = drug_exposure_end_date) %>% 
  mutate(drug_concept_id = drug_source_concept_id)


write.csv(drug_exposure_temp, file = "drug_exposure_mapped.csv")
