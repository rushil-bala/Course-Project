# Appropriately set the working directory.

# Load the required libraries.

library(data.table)
library(dplyr)

# Check and download the raw data.

rawdataname <- "raw_data.zip"
rawdataurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists(rawdataname)) {
  download.file(rawdataurl, rawdataname, method="curl")
}
if (!file.exists("UCI HAR Dataset")) { 
  unzip(rawdataname)
}

# Read features and activities.

features <- read.table("UCI HAR Dataset/features.txt", col.names = c("FN", "Functions"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("Code", "Activity"))

# Read subject_test, x_test and y_test.

subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "Subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$Functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "Code")

# Read subject_train, x_train and y_train.

subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "Subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$Functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "Code")

# Merge x_train and x_test.

mergedx <- rbind(x_train, x_test)

# Merge y_train and y_test.

mergedy <- rbind(y_train, y_test)

# Merge subject_train and subject_test.

mergedsub <- rbind(subject_train, subject_test)

# Merge mergedsub, mergedy and mergedx.

mergeddata <- cbind(mergedsub, mergedy, mergedx)

# STEP 2.

newdata <- mergeddata %>%
  select(Subject, Code, contains("mean"), contains("std"))

# STEP 3.

newdata$code <- activities[newdata$Code, 2]
names(newdata)[2] = "Activity"

# STEP 4.

names(newdata) <- gsub("^t", "Time ", names(newdata))
names(newdata) <- gsub("^f", "Frequency ", names(newdata))
names(newdata) <- gsub("angle", "Angle ", names(newdata))
names(newdata) <- gsub("Body", "Body ", names(newdata))
names(newdata) <- gsub("Body Body ", "Body ", names(newdata))
names(newdata) <- gsub("Acc", "Accelerometer ", names(newdata))
names(newdata) <- gsub("Gyro", "Gyroscope ", names(newdata))
names(newdata) <- gsub("Mag", "Magnitude ", names(newdata))
names(newdata) <- gsub("Jerk", "Jerk ", names(newdata))
names(newdata) <- gsub(".tBody", "Time Body", names(newdata))
names(newdata) <- gsub(".gravity", " Gravity ", names(newdata))
names(newdata) <- gsub(".mean", "Mean ", names(newdata))
names(newdata) <- gsub(".std", "STD ", names(newdata))
names(newdata) <- gsub("Mean Freq", "Mean Frequency", names(newdata))
names(newdata) <- gsub("GravityAccelerometer", "Gravity Accelerometer", names(newdata))

# STEP 5.

finaldata <- newdata %>%
  group_by(Subject, Activity) %>%
  summarise_all(funs(mean))

# Write finaldata.

write.table(finaldata, "Final_Data.txt")