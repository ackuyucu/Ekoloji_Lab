
# Verilerin yüklenmesi A alanı Lab B alanı Doga
AB_data <- read.csv2("Data/Data_agac.csv",sep = ";",header = TRUE,col.names = c("A","B"))
AB_data

# Verileri A ve B alanı olmak üzere iki kısma ayırın ve boş verileri atın (NA)
alan_A <- AB_data$A
alan_B <- na.omit(AB_data$B)

# Tanımlayıcı istatistik
summary(alan_A)

summary(alan_B)

# standart sapma ve varyasyon

sd(alan_A)

sd(alan_B)

# varyans ve örneklem büyüklüklerini ayrı olarak belirleyin
var_A <- var(alan_A)

var_B <- var(alan_B)

n_A <- length(alan_A)

n_B <- length(alan_B)



# T değerinin bulunması, Cohen'in değerine göre (uzun yol)


t_value <- (mean(alan_A)-mean(alan_B))/sqrt((var_A/n_A+var_B/n_B))

t_value

# P değerinin bulunması, çift taraflı olduğu için ikiyle çarpılması gereklidir

pt(t_value,df=22,lower.tail = FALSE, log.p = FALSE)*2    


# Histogram grafikleri

par(mfrow = c(1,2))

hist(alan_A, xlab = "Ağaç Sayısı", ylab = "Sıklık", main = "A alanı")

hist(alan_B,xlab = "Ağaç Sayısı", ylab = "Sıklık", main = "B alanı")

# T testi ile alanların karşılaştırılması (kısayol)

t.test(alan_A,alan_B,alternative = "two.sided",paired = FALSE)


