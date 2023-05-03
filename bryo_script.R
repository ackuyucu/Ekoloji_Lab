# Verileri okuyun
par(mfrow = c(1,1))
Bytho_data <- read.csv("Data/Bytho.csv",header = TRUE)
head(Bytho_data)
names(Bytho_data)

# verileri duzenlemek
Bytho_data$Depth <- factor(Bytho_data$Depth)
Bytho_data <- na.omit(Bytho_data)

# Distal igne uzunlugu histogramlari
with(Bytho_data,hist(Spine_length))
with(Bytho_data,hist(Body_length))

with(Bytho_data,boxplot(Body_length~Depth,xlab = "Derinlik (metre)", ylab = "Vucut Uzunlugu (mm)",col = "red"))

# Derinlige bagli olarak vucut uzunlugu karsilastirmasi
t.test(Bytho_data$Body_length~Bytho_data$Depth)
sd(subset(Bytho_data,Depth == 45)$Body_length)
sd(subset(Bytho_data,Depth == 60)$Body_length)

# Diken uzunlugu
with(Bytho_data,boxplot(Spine_length~Depth,
                       xlab = "Derinlik (metre)", ylab = "Diken Uzunlugu (mm)",col = "blue"))



# Korelasyon
cor(Bytho_data$Body_length,Bytho_data$Spine_length)
cor.test(Bytho_data$Body_length,Bytho_data$Spine_length)

plot(Bytho_data$Body_length, Bytho_data$Spine_length,
      xlab = "Vucut uzunlugu", ylab = "Diken uzunlugu")

# Lineer regresyon
model_1 <- lm(data = Bytho_data, Spine_length ~ Body_length)

summary(model_1)

abline(model_1, col = "red")


# Peki gruplarin kendi icinde durum nedir
mg_45 <- subset(Bytho_data,Depth==45)
mg_60 <- subset(Bytho_data,Depth==60)

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

