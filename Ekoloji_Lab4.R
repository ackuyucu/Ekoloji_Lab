set.seed(15)

sample_1 <- sample(1:100,30,replace = TRUE)
sample_1

alan_verisi <- read.csv2("Data/Alan_tablo.csv")

summary(alan_verisi)

alan_tablo <- data.frame(table(alan_verisi$A))

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

pois_tablo[,2] <- (f_ort^(alan_tablo[,1])/(exp(1)^f_ort*factorial(alan_tablo[,1])))

pois_tablo[,3] <- pois_tablo[,2]*f_sum

pois_tablo[,4] <- alan_tablo[,2]

# Gözlenen ve beklenen değerler için ki kare testi

chisq.test(pois_tablo[,3],pois_tablo[,4])

