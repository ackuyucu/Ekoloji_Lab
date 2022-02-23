
Bryo_data <- read.csv("Bryo.csv")
head(Bryo_data)
with(Bryo_data,hist(Body_length,main = "",xlab = "V.uzunlugu", ylab = "Frekans",col = "red"))
with(Bryo_data,hist(Spine_length,main = "",xlab = "Diken uzunlugu", ylab = "Frekans", col = "blue"))
with(Bryo_data,boxplot(Body_length~Depth,col = "red",xlab = "Derinlik (m)",ylab = "V.uzunlugu"))
with(Bryo_data,boxplot(Spine_length~Depth,col = "blue",xlab = "Derinlik (m)",ylab = "D.uzunlugu"))

cor(Bryo_data$Body_length,Bryo_data$Spine_length)
cor.test(Bryo_data$Body_length,Bryo_data$Spine_length, method=c("pearson", "kendall", "spearman"))
with(Bryo_data,plot(Body_length,Spine_length,xlab = "V.uzunlugu (mm)",ylab = "Diken uzunlugu (mm)"))
model1 <- lm(data = Bryo_data,Spine_length~Body_length)
abline(model1)
