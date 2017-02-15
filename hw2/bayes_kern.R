#########
# Setup #
#########

library(foreach)
library(doParallel)
library(MVN)

data <- read.csv("magic04.data", header=F, sep=",")
train.size <- 13000 # Given by homework specification
start.time <- proc.time()

########################
# Naive Bayes (Kernel) #
########################

cl <- makeCluster(4)
registerDoParallel(cl)

err <- foreach (i=1:100, .combine = c) %dopar% {
    library(klaR)
    library(caret)

    data <- data[sample(nrow(data)),] # Randomize the data set

    train <- data[1:train.size, 1:10]
    test <- data[(train.size+1):nrow(data), 1:10]
    train.cl <- factor(data[1:train.size, 11])
    test.cl <- factor(data[(train.size+1):nrow(data), 11]);

    model <- NaiveBayes(x = train, grouping = train.cl, usekernel=TRUE)
    predict.cl <- predict(model, test)$class
    sum(test.cl != predict.cl) / nrow(test)
}

stopCluster(cl)
acc <- 1.0 - mean(err)

# About 76.2375%
print(paste("Naive Bayes (Kernel) - Accuracy: ", acc))
print((proc.time() - start.time))
