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

t.test(kuadrat_10,kuadrat_30,alternative = "two sided", paired = FALSE)

# Transekt verilerinin alınması

transekt_3 <- na.omit(orneklem_veri$transekt_3)
transekt_6 <- na.omit(orneklem_veri$transekt_6)

# Transekt verilerinin özetlenmesi

summary(transekt_3)

summary(transekt_6)

# Transekt verilerinin t testi ile değerlendirilmesi

t.test(transekt_3,transekt_6,alternative = "two sided", paired = FALSE)


# 2. kısım Birleşik verilerin değerlendirilmesi

birlesik_veri <- read.csv2("Data/Ekoloji_lab3_birlesik_veri.csv")

# Kuadrat verilerinin alınması

kuadrat_40 <- na.omit(birlesik_veri$kuadrat_40)
kuadrat_120 <- na.omit(birlesik_veri$kuadrat_120)

# Kuadrat verilerinin özetlenmesi

summary(kuadrat_40)

summary(kuadrat_120)

# Kuadrat verilerinin t testi ile karşılaştırılması

t.test(kuadrat_40,kuadrat_120,alternative = "two sided", paired = FALSE)

# Transekt verilerinin alınması

transekt_12 <- na.omit(orneklem_veri$transekt_12)
transekt_24 <- na.omit(orneklem_veri$transekt_24)

# Transekt verilerinin özetlenmesi

summary(transekt_12)

summary(transekt_24)

# Transekt verilerinin t testi ile değerlendirilmesi

t.test(transekt_12,transekt_24,alternative = "two sided", paired = FALSE)



