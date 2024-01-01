library(tidyverse)

#Import des tables MIMIC-IV et OMOP
omop_measurement <- read.csv("measurement/measurement.csv")
mimic_labevents <- read.csv("measurement/labevents.csv")
mimic_labitems <-  read.csv("measurement/d_labitems.csv")


measurement_temp <- omop_measurement[FALSE, ]

#labevents est trop volumineux pour Rabbit in a hat on va donc le raccourcir 
mimic_labevents_subset = mimic_labevents[1:1000, ]
write.csv(mimic_labevents_subset, file = "measurement/labevents_subset.csv",  row.names = FALSE)

#Selection des colonnes à garder
mimic_labevents_selected <- mimic_labevents[, c("labevent_id","subject_id","hadm_id","itemid","charttime","valuenum","valueuom","value")]

#Travail sur itemid pour avoir une source de données pour Usagi
unique_itemid <- unique(mimic_labevents$itemid)
unique_itemid_df <- data.frame(itemid = unique_itemid)
mimic_labitems <- mimic_labitems[, c("itemid","label")]
unique_itemid_df <- inner_join(unique_itemid_df, mimic_labitems, by = "itemid")
write.csv(unique_itemid_df, file = "measurement/unique_itemid.csv")


#Après un loooooooong mapping sur Usagi on importe lab_map.csv
lab_map <- read.csv("measurement/lab_map.csv")
#On ne garde que les colonnes qui nous intéressent 
lab_map <- lab_map[, c("source_code", "target_concept_id")]

#Jointure
mimic_labevents1 <- mimic_labevents_selected %>%
  left_join(lab_map, by = c("itemid" = "source_code")) %>%
  select(-itemid, itemid = target_concept_id)


#remplir maintenant drug_exposure_temp
#on s'assure d'avoir le même nombre de rows
if(nrow(measurement_temp) == 0) {
  measurement_temp <- measurement_temp[seq_len(nrow(mimic_labevents1)), ]
}

measurement_temp$person_id <- mimic_labevents1$subject_id
measurement_temp$visit_occurrence_id <- mimic_labevents1$hadm_id
measurement_temp$measurement_id <- mimic_labevents1$labevent_id
measurement_temp$value_source_value <- mimic_labevents1$value
measurement_temp$measurement_date <- mimic_labevents1$charttime
measurement_temp$value_as_number <- mimic_labevents1$valuenum
measurement_temp$unit_source_value <- mimic_labevents1$valueuom
measurement_temp$measurement_concept_id <- mimic_labevents1$itemid

measurement_temp$measurement_type_concept_id <- 32856


#Gérer les NA car sinon la base de donnée ne les acceptera pas
measurement_temp[measurement_temp == "NA"] <- ""

# Save the CSV file
write.csv(measurement_temp, file = "measurement/measurement_mapped.csv", na = "", row.names = FALSE)

