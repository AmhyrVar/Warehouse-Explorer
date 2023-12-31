library(tidyverse)

#importer la table pharmacy de MIMIC-IV
pharmacy <- read.csv("drug_exposure/pharmacy.csv")

#importer la table drug_exposure OMOP exportée depuis DBeaver
drug_exposure <- read.csv("drug_exposure/drug_exposure.csv")

#Créer un drug_exposure_temp vide (sans ses lignes en ne gardant que les colonnes)
drug_exposure_temp <- drug_exposure[FALSE, ]

#On selectionne les colonnes à garder dans la table pharmacy et on supprime les rows avec des vides
pharmacy_selected <- pharmacy[, c("subject_id", "hadm_id", "pharmacy_id", "starttime", "stoptime", "medication")]
pharmacy_clean <- pharmacy_clean[rowSums(pharmacy_clean == "") == 0, ]

#Travail sur la colonne medication pour avoir une source de données pour Usagi
unique_medication <- unique(pharmacy_clean$medication)
unique_medication_df <- data.frame(medication = unique_medication)
write.csv(unique_medication_df, file = "drug_exposure/unique_medication.csv")

#Après un long mapping sur Usagi on importe drugs_map.csv
drugs_map <- read.csv("drug_exposure/drugs_map.csv")
#On ne garde que les colonnes qui nous intéressent à savoir les valeurs dans pharmacy et les concept_id OMOP
drugs_map <- drugs_map[, c("source_code_description", "target_concept_id")]

pharmacy_clean2 <- pharmacy_clean %>%
  left_join(drugs_map, by = c("medication" = "source_code_description")) %>%
  # Selecting necessary columns and renaming the target_concept_id to medication
  select(-medication, medication = target_concept_id)

#remplir maintenant drug_exposure_temp
#on s'assure d'avoir le même nombre de rows
if(nrow(drug_exposure_temp) == 0) {
  drug_exposure_temp <- drug_exposure_temp[seq_len(nrow(pharmacy_clean2)), ]
}

#On remplit les colonnes avec celles qui leur correspondent dans pharmacy
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

#32849 pour drug_type_concept_id car c'est une colonne qui ne doit pas rester vide dans les parametres de la base de données
drug_exposure_temp$drug_type_concept_id <- 32849

#Gérer les NA car sinon la base de donnée ne les acceptera pas
drug_exposure_temp[drug_exposure_temp == "NA"] <- ""

# Save the CSV file
write.csv(drug_exposure_temp, file = "drug_exposure/drug_exposure_mapped.csv", na = "", row.names = FALSE)



