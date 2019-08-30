# In this project, the reshape2 package is used, therefore first we have to load the package

library(reshape2)


# Code to download the provided data set for the assignment and unzip it 

filename <- "getdata_dataset.zip"

if (!file.exists(filename)){
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
        download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
        unzip(filename) 
}

# The below is the R script run_analysis.R which will do the following steps as per the requirement

# First, loading the activity labels and features of the downloaded files
Activity_Labels <- read.table("UCI HAR Dataset/activity_labels.txt")
Activity_Labels[,2] <- as.character(Activity_Labels[,2])
Features <- read.table("UCI HAR Dataset/features.txt")
Features[,2] <- as.character(Features[,2])

# Second, Extracting only the measurements on the mean and standard deviation for each measurement.

Required_Features <- grep(".*mean.*|.*std.*", Features[,2])
Required_Features.names <- Features[Required_Features,2]
Required_Features.names = gsub('-mean', 'Mean', Required_Features.names)
Required_Features.names = gsub('-std', 'Std', Required_Features.names)
Required_Features.names <- gsub('[-()]', '', Required_Features.names)


# Now, load the datasets from the downloaded files and combining them as follows: 
X_Training <- read.table("UCI HAR Dataset/train/X_train.txt")[ Required_Features]
Training_Activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
Training_Subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
X_Training <- cbind(Training_Subjects, Training_Activities, X_Training)

X_Testing <- read.table("UCI HAR Dataset/test/X_test.txt")[ Required_Features]
Testing_Activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
Testing_Subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
X_Testing <- cbind(Testing_Subjects, Testing_Activities, X_Testing)

# Now mergeing the datasets and adding labels as follows: 

Meged_Data <- rbind(X_Training, X_Testing)
colnames(Meged_Data) <- c("Subject", "Activity", Required_Features.names)

# Now turning the activities and subjects into factors as follows: 

Meged_Data$Activity <- factor(Meged_Data$activity, levels = Activity_Labels [,1], labels = Activity_Labels [,2])

Meged_Data$Subject <- as.factor(Meged_Data$Subject)

Meged_Data.melted <- melt(Meged_Data, id = c("Subject", "Activity"))
Meged_Data.mean <- dcast(Meged_Data.melted, Subject + Activity ~ variable, mean)

# Finally, writing the tidy data set in txt file
write.table(Meged_Data.mean, "Tidy_Data.txt", row.names = FALSE, quote = FALSE)
