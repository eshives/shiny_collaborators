# Read in all files with collaborator-title pairs
args = commandArgs(trailingOnly = TRUE)
library(tidyverse)

big.file <- read.csv(args[1], stringsAsFactors = FALSE, header=FALSE)
big.file <- as.data.frame(big.file, stringsAsFactors = FALSE)
colnames(big.file) <- c("collabs","titles")

# Filter out abstracts that failed to find a match in the collaborator list
big.file <- big.file %>% filter(collabs!="none")

# Select top 10 collaborators
top10 <- big.file %>% 
  mutate(counting=1) %>%
  arrange(collabs) %>%
  group_by(collabs) %>%
  summarize(freq=sum(counting)) %>%
  top_n(10) %>%
  arrange(-freq)

# Concatenate all titles from one collaborator into a single string
small.file <- data.frame(0)
for (i in 1:dim(top10)[1]){
  small.file[i,1] <- top10[i,1]
  onlyi <- big.file %>% filter(collabs==as.character(top10[i,1]))
  all.titles <- c("")
  for (j in 1:length(onlyi)){
    all.titles <- paste(all.titles, onlyi[j,2])
  }
  small.file[i,2] <- all.titles
}
colnames(small.file) <- c("collabs","titles")

# Output file with collaborator and string of all titles into a csv file
write.csv(small.file, file ="topten.csv")
