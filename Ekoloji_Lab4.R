# Grup numaraniza gore set.seed() belirleyin

set.seed(14)

Random_sample <- sample(1:100,size = 30,replace = F)

# Asagidaki Sayilari kaydedin
Random_sample

# Öncelikli olarak alan verisinin okunması verilerinizi öncelikli olarak
# Alan_tablo.csv içerisine kaydedin


alan_verisi <- read.csv("Data/Alan_tablo.csv")

summary(alan_verisi)

alan_tablo <- data.frame(table(alan_verisi$Birey))

alan_tablo <-  apply(as.matrix.noquote(alan_tablo),2, as.numeric)

colnames(alan_tablo) <- c("Sayi","Frekans")

alan_tablo

# Çarpımlar toplamı

f_x_sum <- sum(alan_tablo[,1] * alan_tablo[,2])

# Alt kuadrat sayısı toplamı
f_sum <- sum(alan_tablo[,2])


# Kuadrat başına düşen aritmetik ortalama
f_ort <- f_x_sum/f_sum
f_ort

# Poisson olasılığından beklenen tablonun oluşturulması

kuad_s <- (length(alan_tablo[,1]))

pois_tablo <- matrix(nrow = kuad_s,ncol = 4,byrow = TRUE)

pois_tablo[,1] <- alan_tablo[,1]

pois_tablo[,2] <- (f_ort^(alan_tablo[,1])/(exp(f_ort)*factorial(alan_tablo[,1])))

pois_tablo[,3] <- pois_tablo[,2]*f_sum

pois_tablo[,4] <- alan_tablo[,2]

# Gözlenen ve beklenen değerler için ki kare testi

chisq.test(pois_tablo[,3],pois_tablo[,4])

hist(alan_verisi$Birey, xlab = "Birey Sayisi", ylab = "Frekans",
     main = "")
