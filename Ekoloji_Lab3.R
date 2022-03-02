# Ekoloji Lab 3 TEMEL ÖRNEKLEME YÖNTEMLERİ

# Bu çalışmada öncelikli olarak doldurduğunuz tabloları verilmiş olan .csv uzantılı
# dosyaya kaydedin

# 1. kısım grup verilerinin değerlendirilmesi
# Verilerin okunması

orneklem_veri <- read.csv2("Data/Ekoloji_lab3_veri.csv")

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

