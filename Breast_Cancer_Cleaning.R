#
# Creator: Andrew Disher
# Date: 5/2/2022
# Affiliation: UMASS Dartmouth
# Class: CIS-530 Advanced Data Mining
# Professor: Dr. Ming Shao
#
# Assignment: Final Project
#
# TASK: Clean the Breast Cancer Wisconsin (Diagnostic) Data Set found at this link: 
#       https://www.kaggle.com/datasets/uciml/breast-cancer-wisconsin-data
#


# Import the data
data <- read.csv("~/UMASS Dartmouth/Classes/Spring 2022/Data Mining/Project/Data Sets/Breast Cancer Data Set/data.csv")
View(data)

# Remove the last column (column 33). It is not a feature, it is purely the result of a misformatted .csv file.
data <- data[, -33]

# Additionally, we do not require the first column, called "id".
data <- data[, -1]

# Now, we must check for things like missing and null values in the data set. 

cleaningDataFrame <- data.frame(Names = colnames(data), Number_NA = numeric(31), Number_Null = numeric(31))

for (column in 1:ncol(data)) {
  numberNA = 0
  numberNull = 0
  for (row in 1:nrow(data)) {
    if(is.na(data[row, column]) == TRUE){numberNA = numberNA + 1}
    else if(is.null(data[row, column]) == TRUE){numberNull = numberNull + 1}
  }
  cleaningDataFrame[column, 2] = numberNA
  cleaningDataFrame[column, 3] = numberNull
}

# NOTE: According to the values stored in our data frame, there are no NA or NULL values in our data set. 

# Now, convert the response variable column `diagnosis` to binary 0/1
for (row in 1:nrow(data)) {
  if(data[row, "diagnosis"] == 'B'){data[row, "diagnosis"] <- 0}
  else if(data[row, "diagnosis"] == 'M'){data[row, "diagnosis"] <- 1}
}
data$diagnosis <- as.numeric(data$diagnosis)


# The data set is cleaned, and all of the features that we have seem to be in the format that we need, so write the 
# new "data" data frame to a csv file. 

write.csv(data, file = "Breast_Cancer_Data_Set.csv", sep = ",")
