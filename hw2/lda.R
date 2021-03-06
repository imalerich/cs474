#########
# Setup #
#########

library('foreach')
library('doParallel')
library('MVN')

# Read, scale, & center our data.
data <- read.csv("magic04.data", header=F, sep=",")
data[1:nrow(data), 1:10] = scale(data[1:nrow(data), 1:10], center=T, scale=T)
train.size <- 13000 # Given by homework specification
start.time <- proc.time()

######################
# Test for Normality #
######################

sink("g.norm.txt", append=F, split=F)
data <- data[sample(nrow(data)),] # Randomize the data set
hz = hzTest(data[data[,11]=='g',1:10], cov=TRUE, qqplot=FALSE)
print(hz)
# uniPlot(data, type="histogram")
sink()
 
#######
# LDA #
#######

registerDoParallel(8)

err <- foreach (i=1:100, .combine = c) %dopar% {
    library(MASS)

    data <- data[sample(nrow(data)),] # Randomize the data set

    train <- data[1:train.size, 1:10]
    test <- data[(train.size+1):nrow(data), 1:10]
    train.cl <- factor(data[1:train.size, 11])
    test.cl <- factor(data[(train.size+1):nrow(data), 11]);

    model <- lda(x = train, grouping = train.cl)
    predict.cl <- predict(model, test)$class
    sum(test.cl != predict.cl) / nrow(test)
}

stopImplicitCluster()
acc <- 1.0 - mean(err)

# About 78.429%
print(paste("LDA - Accuracy: ", acc))
print(proc.time() - start.time)
