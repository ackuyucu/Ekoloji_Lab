# Verileri okuyun
par(mfrow = c(1,1))
Bryo_data <- read.csv("Data/Bryo.csv",header = TRUE)
head(Bryo_data)
names(Bryo_data)

# verileri duzenlemek
Bryo_data$Depth <- factor(Bryo_data$Depth)
Bryo_data <- na.omit(Bryo_data)

# Distal igne uzunlugu histogramlari
with(Bryo_data,hist(Spine_length))
with(Bryo_data,hist(Body_length))

with(Bryo_data,boxplot(Body_length~Depth,xlab = "Derinlik (metre)", ylab = "Vucut Uzunlugu (mm)",col = "red"))

# Derinlige bagli olarak vucut uzunlugu karsilastirmasi
t.test(Bryo_data$Body_length~Bryo_data$Depth)
sd(subset(Bryo_data,Depth == 45)$Body_length)
sd(subset(Bryo_data,Depth == 60)$Body_length)

# Diken uzunlugu
with(Bryo_data,boxplot(Spine_length~Depth,
                       xlab = "Derinlik (metre)", ylab = "Diken Uzunlugu (mm)",col = "blue"))



# Korelasyon
cor(Bryo_data$Body_length,Bryo_data$Spine_length)
cor.test(Bryo_data$Body_length,Bryo_data$Spine_length)

plot(Bryo_data$Body_length, Bryo_data$Spine_length,
      xlab = "Vucut uzunlugu", ylab = "Diken uzunlugu")

# Lineer regresyon
model_1 <- lm(data = Bryo_data, Spine_length ~ Body_length)

summary(model_1)

abline(model_1, col = "red")


# Peki gruplarin kendi icinde durum nedir
mg_45 <- subset(Bryo_data,Depth==45)
mg_60 <- subset(Bryo_data,Depth==60)

par(mfrow = c(1,2))
with(data = mg_45, hist(Body_length,xlab = "V.uzunlugu (mm)", col = "red", 
                        main = "45 metre"))
with(data = mg_60, hist(Body_length,xlab = "V.uzunlugu (mm)", col = "blue",
                        main = "60 metre"))

with(data = mg_45, hist(Spine_length,xlab = "D.uzunlugu (mm)", col = "red",
                        main = "45 metre"))

with(data = mg_60, hist(Spine_length,xlab = "D.uzunlugu (mm)", col = "blue",
                        main = "60 metre"))

# 45 metre grubu icin korelasyon ve grafik

par(mfrow = c(1,2))
cor.test(mg_45$Body_length,mg_45$Spine_length)

plot(mg_45$Body_length,mg_45$Spine_length,
     xlab = "Vucut uzunlugu", ylab = "Diken uzunlugu",main = "45 metre")

model_45 <- lm(data = mg_45, Spine_length ~ Body_length)
summary(model_45)

abline(model_45, col = "red")



# 60 metre grubu icin korelasyon ve grafik
cor.test(mg_60$Body_length,mg_60$Spine_length)

plot(mg_60$Body_length,mg_60$Spine_length,
     xlab = "Vucut uzunlugu", ylab = "Diken uzunlugu",main = "60 metre")

model_60 <- lm(data = mg_60, Spine_length ~ Body_length)
summary(model_60)

abline(model_60, col = "blue")

