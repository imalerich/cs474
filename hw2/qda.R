#########
# Setup #
#########

library('foreach')
library('doParallel')

# Read, scale, & center our data.
data <- read.csv("magic04.data", header=F, sep=",")
data[1:nrow(data), 1:10] = scale(data[1:nrow(data), 1:10], center=T, scale=T)
train.size <- 13000 # Given by homework specification
start.time <- proc.time()

#######
# QDA #
#######

registerDoParallel(8)

err <- foreach (i=1:100, .combine = c) %dopar% {
    library(MASS)

    data <- data[sample(nrow(data)),] # Randomize the data set

    train <- data[1:train.size, 1:10]
    test <- data[(train.size+1):nrow(data), 1:10]
    train.cl <- factor(data[1:train.size, 11])
    test.cl <- factor(data[(train.size+1):nrow(data), 11]);

    model <- qda(x = train, grouping = train.cl)
    predict.cl <- predict(model, test)$class
    sum(test.cl != predict.cl) / nrow(test)
}

stopImplicitCluster()
acc <- 1.0 - mean(err)

# About 78.4276%
print(paste("QDA - Accuracy: ", acc))
print((proc.time() - start.time))
