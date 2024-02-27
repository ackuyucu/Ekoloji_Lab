library(datasets)
head(iris)
summary(iris$Species)

# Temel grafikler

head(iris)
summary(iris$Species)

par(mfrow=c(1,1))
hist(iris$Sepal.Width)

# daha iyi grafikler


hist(iris$Sepal.Width,main = "Histogram",
      xlab = "Sepal Genisligi", ylab = "Frekans", col = "red")


boxplot(iris$Sepal.Width, main = "Kutu plot grafiği",
        ylab = "Sepal Genisligi", col = "red")


hist(iris$Petal.Length,main = "Histogram",
     xlab = "Petal Genisligi", ylab = "Frekans", col = "blue")

setosa_data <- iris_data[iris_data$Species == "setosa",]

virginica_data <- iris_data[iris_data$Species == "virginica",]

versicolor_data <- iris_data[iris_data$Species == "versicolor",]

par(mfrow = c(1,3))

hist(setosa_data$Petal.Length,main = "Histogram",
     xlab = "Petal Genisligi Setosa", ylab = "Frekans", col = "blue")

hist(virginica_data$Petal.Length,main = "Histogram",
     xlab = "Petal Genisligi virginica", ylab = "Frekans", col = "green")

hist(versicolor_data$Petal.Length,main = "Histogram",
     xlab = "Petal Genisligi versicolor", ylab = "Frekans", col = "red")


# Daha da iyi grafikler !

library("tidyverse")

ggplot(data = iris_data, aes(y = Petal.Length, x = Species)) +
  geom_boxplot(aes(fill = Species))


ggplot(data = iris_data, aes(x = Petal.Length)) +
  geom_histogram(aes(fill = Species), col = "black", alpha = 0.5) +
  xlab("Petal Genisligi") +
  ylab("Sayi")


# Temel testler

summary(versicolor_data)

summary(virginica_data)

t.test(versicolor_data$Petal.Length,virginica_data$Petal.Length,
       alternative = "two.sided",paired = F)
