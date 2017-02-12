#########
# Setup	#
#########

library(MASS)

data <- data.frame(
    c(0, 1, 1, 1, 0, 1),
    c(0, 0, 0, 1, 1, 1),
    c(0, 1, 0, 1, 1 ,0),
    c(0, 1, 0, 1, 1 ,0)
)

names(data) <- c("F1", "F2", "F3", "CLASS")
test <- c(0, 0, 1)
 
#######
# QDA #
#######

train.size <- nrow(data)
train <- data[1:train.size, 1:3]
train.cl <- factor(data[1:train.size, 4])

model <- qda(x = train, grouping = train.cl)
predict.cl <- predict(model, test)$class
print(predict.cl)
