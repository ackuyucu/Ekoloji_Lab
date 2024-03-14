# Ekoloji Lab 3 TEMEL ÖRNEKLEME YÖNTEMLERİ

# Grup numaraniza gore set.seed() belirleyin

set.seed(14)


transekt_sample_3 <- sample(1:100,size = 3,replace = F)
transekt_sample_6 <- sample(1:100, size = 6, replace = F)

Kuadrat_sample_10 <- sample(1:100,size = 10,replace = F)
Kuadrat_sample_30 <- sample(1:100,size = 30,replace = F)

# Asagidaki Sayilari kaydedin
transekt_sample_3

transekt_sample_6

Kuadrat_sample_10

Kuadrat_sample_30

# Bu çalışmada öncelikli olarak doldurduğunuz tabloları verilmiş olan .csv uzantılı
# dosyaya kaydedin

# 1. kısım grup verilerinin değerlendirilmesi
# Dikkat verileri okumadan önce labda elde ettiğiniz verileri
# Data klasörü içindeki Ekoloji_lab3_veri.csv dosyasına kaydedin
# Verilerin okunması

orneklem_veri <- read.csv("Data/Ekoloji_lab3_veri.csv", sep = ",")

# Kuadrat verilerinin alınması

kuadrat_10 <- na.omit(orneklem_veri$kuadrat_10)
kuadrat_30 <- na.omit(orneklem_veri$kuadrat_30)

# Kuadrat verilerinin özeti

summary(kuadrat_10)

summary(kuadrat_30)

# Kuadrat verilerinin t testi ile karşılaştırılması

t.test(kuadrat_10,kuadrat_30,alternative = "two.sided", paired = FALSE)

# Transekt verilerinin alınması

transekt_3 <- na.omit(orneklem_veri$transekt_3)
transekt_6 <- na.omit(orneklem_veri$transekt_6)

# Transekt verilerinin özetlenmesi

summary(transekt_3)

summary(transekt_6)

# Transekt verilerinin t testi ile değerlendirilmesi

t.test(transekt_3,transekt_6,alternative = "two.sided", paired = FALSE)


# 2. kısım Birleşik verilerin değerlendirilmesi

# Burada birlesik verileri kullaniyoruz

birlesik_veri <- read.csv2("Data/Ekoloji_lab3_birlesik_veri.csv")

# Kuadrat verilerinin alınması A alanı

kuadrat_40_A <- na.omit(birlesik_veri$kuadrat_40_A)
kuadrat_120_A <- na.omit(birlesik_veri$kuadrat_120_A)

# Kuadrat verilerinin özetlenmesi A alanı

summary(kuadrat_40_A)

summary(kuadrat_120_A)

# Kuadrat verilerinin t testi ile karşılaştırılması A alanı

t.test(kuadrat_40_A,kuadrat_120_A,alternative = "two.sided", paired = FALSE)

# Transekt verilerinin alınması A alanı

transekt_12_A <- na.omit(birlesik_veri$transekt_12_A)
transekt_24_A <- na.omit(birlesik_veri$transekt_24_A)

# Transekt verilerinin özetlenmesi

summary(transekt_12_A)

summary(transekt_24_A)

# Transekt verilerinin t testi ile değerlendirilmesi A alani icinde

t.test(transekt_12_A,transekt_24_A,alternative = "two.sided", paired = FALSE)


# B Alani

# Kuadrat verilerinin alınması B alanı

kuadrat_40_B <- na.omit(birlesik_veri$kuadrat_40_B)
kuadrat_120_B <- na.omit(birlesik_veri$kuadrat_120_B)

# Kuadrat verilerinin özetlenmesi B alanı

summary(kuadrat_40_B)

summary(kuadrat_120_B)

# Kuadrat verilerinin t testi ile karşılaştırılması B alanı

t.test(kuadrat_40_B,kuadrat_120_B,alternative = "two.sided")

# Transekt verilerinin alınması B alanı

transekt_12_B <- na.omit(birlesik_veri$transekt_12_B)
transekt_24_B <- na.omit(birlesik_veri$transekt_24_B)

# Transekt verilerinin özetlenmesi

summary(transekt_12_B)

summary(transekt_24_B)

# Transekt verilerinin t testi ile değerlendirilmesi B alani icinde

t.test(transekt_12_B,transekt_24_B,alternative = "two.sided")
# 3. Kısım A ve B alanlarının birleşik veride karşılaştırılması

# Kuadrat verileri için

t.test(kuadrat_40_A,kuadrat_40_B, alternative = "two.sided", paired = FALSE)

t.test(kuadrat_120_A,kuadrat_120_B, alternative = "two.sided", paired = FALSE)

# Transekt verileri icin

t.test(transekt_12_A,transekt_12_B,alternative = "two.sided", paired = FALSE)

t.test(transekt_24_A,transekt_24_B, alternative = "two.sided", paired = FALSE)


# Kendi verilerinizi birleşik tablo verileri ile karşılaştırın
# A alanı için kuadrat verileri

t.test(kuadrat_30,kuadrat_120_A, alternative = "two.sided", paired = FALSE)

# B alanı için kuadrat verileri

t.test(kuadrat_30,kuadrat_120_B, alternative = "two.sided", paired = FALSE)

# A alanı için transekt verileri

t.test(transekt_6,transekt_24_A, alternative = "two.sided", paired = FALSE)

# B alanı için transekt verileri

t.test(transekt_6,transekt_24_B, alternative = "two.sided", paired = FALSE)

