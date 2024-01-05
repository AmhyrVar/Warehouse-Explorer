CONCEPT <- read_delim("concepts/CONCEPT.csv", delim = "\t", escape_double = FALSE, trim_ws = TRUE)
write.csv(drug_exposure_temp, file = "concepts/drug_exposure_mapped.csv", na = "", row.names = FALSE)

write.csv(CONCEPT_snomed, file = "actual/subset_rxnorm.csv", na = "", row.names = FALSE)
write.csv(CONCEPT_SNOMED, file = "actual/subset_snomed1.csv", na = "", row.names = FALSE)
machin2 <- read_csv("drug_exposure/machin2.csv")


concept_snomed <- read.csv("actual/concept_snomed1.csv")
concept_rxnorm <- read.csv("actual/concept_rxnorm.csv")
drugz <- read.csv("drug_exposure/drug_exposure_mapped.csv")

drug_snomed <- concept_snomed %>%
  filter(domain_id == "Drug")
  
  
drug_rxnorm <- concept_rxnorm %>%
  filter(domain_id == "Drug")



#####travail sur machin


machin2 <- machin2 %>% 
  select(-source_code,source_concept_id) %>% 
  rename(vocabulary_id = source_vocabulary_id) %>% 
  rename(concept_name = source_code_description) %>% 
  rename(concept_id = target_concept_id) %>% 
  mutate(domain_id = "Drug",concept_class_id = "Ingredient",standard_concept = "S",concept_code = concept_id)

  mutate(concept_class_id = "Ingredient")

  mutate(standard_concept = "S")


write.csv(machin2, file = "actual/map_drugs_ready.csv", na = "", row.names = FALSE)
CONCEPT <- read_delim("C:/Master/Warehouse/mimic-iv-clinical-database-demo-2.2/Voca/CONCEPT.csv", 
                           delim = "\t", escape_double = FALSE, 
                           trim_ws = TRUE)

CONCEPT <- CONCEPT  %>%
  distinct(concept_id, .keep_all = TRUE)

write.csv(CONCEPT, file = "actual/myconcepts.csv", na = "", row.names = FALSE)

filtered_CONCEPTS <- CONCEPT %>%
  filter(concept_id %in% drugz$drug_concept_id)


write.csv(filtered_CONCEPTS, file = "actual/mydrugconcepts.csv", na = "", row.names = FALSE)
