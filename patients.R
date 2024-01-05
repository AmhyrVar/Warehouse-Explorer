library(tidyverse)

#Import des tables MIMIC-IV et OMOP
mimic_patients <- read.csv("person/patients.csv")
omop_person <- read.csv("person/person.csv")
mimic_admissions <-  read.csv("person/admissions.csv")

#Création d'une table OMOP vide à remplir 
omop_person_temp <- omop_person[FALSE, ]

#On selectionne les colonnes à garder dans la table patients et on supprime les rows avec des vides
patients_selected <- mimic_patients[, c("subject_id", "gender", "anchor_age", "anchor_year", "anchor_year_group")]
patients_clean <- patients_selected[rowSums(patients_selected == "") == 0, ]

#Estimation de l'année de naissance 
patients_clean <- patients_clean %>%
 
  #Extraction de la valeur basse d'anchor_year_group
  mutate(start_year = as.numeric(sub(" .*", "", anchor_year_group))) %>%
  #Calcule de l'année de naissance estimée
  mutate(estimated_year_of_birth = start_year - anchor_age) %>%
  #Suppression de la valeur intermédiaire start_year
  select(-start_year)

#travail sur gender_concept_id
#On vérifie si il n'y a que deux genders dans notre table MIMIC
unique_genders <- unique(patients_clean$gender)
unique_genders_df <- data.frame(genders = unique_genders)
#Export vers Usagi
write.csv(unique_genders_df, file = "person/unique_genders.csv")

#Pas besoin vu que'on a que deux valeurs M et F et que les codes sont facilement accessibles dans Rabbit in a hat
patients_clean <- patients_clean %>%
  mutate(gender = case_when(
    gender == "M" ~ "8507",   # Remplacer "M" par "8507"
    gender == "F" ~ "8532",   # Remplacer "F" par "8532"
    TRUE ~ gender             # Garder les valeurs telles quelles pour les autres cas (au cas où on aurait d'autres genders dans d'autres datasets)
  ))

#drop les colonnes inutiles 
patients_clean <- patients_clean[, c("subject_id", "gender", "estimated_year_of_birth")]

#Travail sur race and ethnicity
mimic_admissions_clean <- mimic_admissions[, c("subject_id", "race")]
unique_races <- unique(mimic_admissions_clean$race)
unique_races_df <- data.frame(races = unique_races)
#Export vers Usagi
write.csv(unique_races_df, file = "person/unique_races.csv")

#Importer la map USAGI
ra_eth_map <- read.csv("person/usagi_race_map.csv")
ra_eth_map <- ra_eth_map[, c("source_code_description","target_concept_id")]


mimic_admissions_clean2 <- mimic_admissions_clean %>%
  left_join(ra_eth_map, by = c("race" = "source_code_description")) %>%
  # Sélectionner les colonnes nécessaires et renommer target_concept_id en race
  select(-race, race = target_concept_id) %>%
  # Ajouter la colonne ethnicity avec les conditions spécifiées
  mutate(ethnicity = case_when(
    race == 38003563 ~ 38003563,  # Si race est égale à 38003563
    TRUE ~ 38003564               # Sinon, dans tous les autres cas
  ))

mimic_admissions_clean2 <- mimic_admissions_clean2 %>%
  mutate(race = ifelse(is.na(race), 0, race))

#Il y a des doublons 
mimic_admissions_unique <- mimic_admissions_clean2 %>%
  distinct(subject_id, .keep_all = TRUE)




#On fait le inner_join
final_patients <- mimic_admissions_unique %>%
  inner_join(patients_clean, by = "subject_id")

#On remplit la table

#on s'assure d'avoir le même nombre de rows
if(nrow(omop_person_temp) == 0) {
  omop_person_temp<- omop_person_temp[seq_len(nrow(final_patients)), ]
}

omop_person_temp$person_id <- final_patients$subject_id
omop_person_temp$year_of_birth <- final_patients$estimated_year_of_birth
omop_person_temp$gender_concept_id <- final_patients$gender
omop_person_temp$race_concept_id <- final_patients$race
omop_person_temp$ethnicity_concept_id <- final_patients$ethnicity

#Gérer les NA car sinon la base de donnée ne les acceptera pas
omop_person_temp[omop_person_temp == "NA"] <- ""

# Save the CSV file
write.csv(omop_person_temp, file = "person/person_mapped.csv", na = "", row.names = FALSE)




####Suite person

omop_person_temp$month_of_birth <- 1
omop_person_temp$day_of_birth <- 1

omop_person_temp1 <- omop_person_temp1 %>%
  mutate(test_birth_datetime = paste(paste(year_of_birth, 
                                           month_of_birth, 
                                           day_of_birth, sep="-"), 
                                     "00:00:00.000"))
omop_person_temp1 <- omop_person_temp1 %>% 
  select(-birth_datetime) %>% 
  rename(birth_datetime = test_birth_datetime)
  
# Save the CSV file
write.csv(omop_person_temp1, file = "person/person_mapped.csv", na = "", row.names = FALSE)

class(omop_person_temp$year_of_birth)
omop_person_temp$year_of_birth <- as.integer(omop_person_temp$year_of_birth)
class(omop_person_temp$ethnicity_concept_id)

omop_person_temp$ethnicity_concept_id <- as.integer(omop_person_temp$ethnicity_concept_id)
omop_person_temp$race_concept_id <- as.integer(omop_person_temp$race_concept_id )
