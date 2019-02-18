# Read in abstract text file
args = commandArgs(trailingOnly = TRUE)
a <- readLines(args[1])

# Get title and author lines and filter title
title<-toString(a[[2]])
title <- gsub("\\,", "", title)
title <- gsub("[^a-zA-Z ]","",title)
authors<-as.character(a[[4]])

# Import college list for comparison
colleges2 <- read.csv(args[2], stringsAsFactors = FALSE)
college <- colleges2$ParentName
college <- unique(college)
college <- college[2:length(college)]

# Find collaborators
n <- 1
collab <- c("none")
for (i in 1:length(college)){
  if( grepl(college[i], authors)==TRUE){
    collab[n]<-college[i]
    n <- n+1
  }
}

# Output collaborators and titles
fileConn = file("*.csv")
for (i in 1:length(collab)){
  writeLines(paste(collab[i], title, sep=','), fileConn) 
}
close(fileConn)