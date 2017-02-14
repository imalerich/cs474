#########
# Setup #
#########

library(MASS)
library(klaR)

data <- data.frame(
    c(0.6585, 2.2460, -2.7665, -1.2565, -0.7973, 1.1170),
    c(0.2444, 0.5281, -3.8303, 3.4912, 1.2288, 2.2637),
    c(0, 0, 0, 1, 1, 1)
)

test <- data.frame(c(0), c(1))

names(data) <- c("F1", "F2", "CLASS")
names(test) <- c("F1", "F2")

train.size <- nrow(data)
train <- data[1:train.size, 1:2]
train.cl <- factor(data[1:train.size, 3])
 
#######
# QDA #
#######

model <- qda(x = train, grouping = train.cl)
predict <- predict(model, test)
print(predict)
print(paste("QDA: ", predict$class))

# Posterior Class Probabilities
# 0: 0.0067895
# 1: 0.9932105

###############
# Naive Bayes #
###############

model <- NaiveBayes(x = train, grouping = train.cl, usekernel=FALSE)
predict <- predict(model, test)
print(predict) 
print(paste("Naive Bayes: ", predict$class))

# Posterior Class Probabilities
# 0: 0.2493135
# 1: 0.7506865
