write.csv(co_temp, file = "condition/condition_occurrence.csv", na = "", row.names = FALSE)



options(scipen=999)
CONCEPT$concept_id <- as.integer(CONCEPT$concept_id)
write.csv(CONCEPT, file = "concepts/CONCEPT.csv", na = "", row.names = FALSE)

write.csv(CONCEPT_RELATIONSHIP, file = "concepts/CONCEPT_RELATIONSHIP.csv", na = "", row.names = FALSE)

library(tidyverse)

rep <- CONCEPT %>%
  group_by(concept_id) %>%
  filter(n() > 1)