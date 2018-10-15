# Getting and Cleaning Data Project 
# Author: B.T.Truong

# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of 
#    each variable for each activity and each subject.

### Task 1: merging the training and the test sets to create one data set
# Loading packages and get and unzip the Dataset
packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
path <- getwd()
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, file.path(path, "data.zip"))
unzip(zipfile = "data.zip")

#Creating a data table containing activity names and feature names 
activity_labels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        ,col.names = c("activityIndex", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("featureIndex", "featureName"))
features$featureName <- gsub("[()]", "", features$featureName)

#Load training datasets into data file
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))
data.table::setnames(train, colnames(train), features$featureName)
trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                         , col.names = c("Activity"))
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)

# Load testing datasets into data file
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))
data.table::setnames(test, colnames(test), features$featureName)
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)
data <- rbind(train, test) # mergng datasets of train and test into data 

### Task 2: 
# Extracts only the measurements on the mean and standard deviation for each measurement. 
selectedFetures <- grep("mean|std", features[, featureName])
data <- data[,selectedFetures, with = FALSE]
    
    
### Task 3. Uses descriptive activity names to name the activities in the data set 
### Task 4. Appropriately labels the data set with descriptive variable names.  
data[["Activity"]] <- factor(data[, Activity]
                                 , levels = activity_labels[["activityIndex"]]
                                 , labels = activity_labels[["activityName"]])
data[["SubjectNum"]] <- as.factor(data[, SubjectNum])
data <- reshape2::melt(data = data, id = c("SubjectNum", "Activity"))

### Task 5. Creates a second, independent tidy data set with the average of 
#           each variable for  each activity and each subject.

data <- reshape2::dcast(data = data, SubjectNum + Activity ~ variable, fun.aggregate = mean)
data.table::fwrite(x = data, file = "tidyData.txt",  row.name=FALSE)


