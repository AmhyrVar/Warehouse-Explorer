library(tidyverse)
condition_occurrence_raw <- read.csv("condition/condition_occurrence_raw.csv")
admissions <- read.csv("condition/admissions.csv")
diagnoses_icd <- read.csv("condition/diagnoses_icd.csv")
d_icd_diagnoses <-  read.csv("condition/d_icd_diagnoses.csv")
final_maps <- read.csv("condition/final_maps.csv")

co_temp <- condition_occurrence_raw[FALSE, ]
if(nrow(co_temp ) == 0) {
  co_temp  <- co_temp [seq_len(nrow(diagnoses_icd)), ]
}

co_temp <- co_temp %>% 
  select(condition_occurrence_id,
         person_id,
         condition_concept_id,
         condition_start_date,
         condition_type_concept_id,
         condition_end_date)

admissions <- admissions %>% 
  select(hadm_id,admittime,dischtime)

diagnoses_icd <- diagnoses_icd %>% 
  left_join(admissions, by="hadm_id")



icd_map <- diagnoses_icd %>% 
  select(icd_code) %>% 
  left_join(d_icd_diagnoses,by='icd_code')

icd_map <- icd_map %>% 
  distinct()

write.csv(icd_map, "condition/icd_map.csv" ,row.names = FALSE)

final_maps <- final_maps[, c("source_code_description", "target_concept_id")]

icd_map <- icd_map %>%
  left_join(final_maps, by = c("long_title" = "source_code_description"))

diagnoses_icd <- diagnoses_icd %>% 
  left_join(icd_map, by = c("icd_code" = "icd_code", "icd_version" = "icd_version"))

co_temp$condition_occurrence_id <- 90000:(89999 + nrow(co_temp))
co_temp$person_id <- diagnoses_icd$subject_id
co_temp$condition_start_date <- diagnoses_icd$admittime
co_temp$condition_end_date <- diagnoses_icd$dischtime
co_temp$condition_type_concept_id <- 32020
co_temp$condition_concept_id <- diagnoses_icd$target_concept_id










opr <- read.csv("drug_exposure/observation_period_raw.csv")
opr_temp <- opr[FALSE, ]
if(nrow(opr_temp) == 0) {
  opr_temp <- opr_temp [seq_len(nrow(co_temp)), ]
}
co_temp <- co_temp %>% 
  select(condition_start_date,condition_end_date,person_id) %>% 
  distinct()


opr_temp$observation_period_id <- 21000:(20999 + nrow(opr_temp))
opr_temp$person_id <- co_temp$person_id
opr_temp$period_type_concept_id <- 44814724
opr_temp$observation_period_start_date <- co_temp$condition_start_date
opr_temp$observation_period_end_date <- co_temp$condition_end_date


write.csv(opr_temp, file = "condition/observation_period.csv", na = "", row.names = FALSE)
