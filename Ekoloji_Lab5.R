





balik_veri <- read.csv2("Data/Bolum5_birlesik.csv",header = TRUE,skip = 1)

# Hamsi vücut uzunluğu ve Vücut genişliği değerlerinin özetlenmesi
# Min:en düşük değer
# Max:en yüksek değer
# Median: Medyan Mean: Ortalama
summary(balik_veri$VU_hamsi)
summary(balik_veri$VG_hamsi)
# Histogram grafikleri

# Hamsilerde vücut uzunluğu ve Vücut genişliği değerleri arasındaki korelasyon
cor(balik_veri$VU_hamsi,balik_veri$VG_hamsi)

# İstavritlerde vücut uzunluğu ve Vücut genişliği değerleri arasındaki korelasyon
cor(balik_veri$VU_istavrit,balik_veri$VG_istavrit)

# Hamsi ve İstavritlerin vücut uzunluğunun t testi ile karşılaştırılması

t.test(balik_veri$VU_hamsi,balik_veri$VU_istavrit,alternative = "two.sided",
                        paired = FALSE)

# Hamsi ve İstavritlerin vücut genişliğinin t testi ile karşılaştırılması

t.test(balik_veri$VG_hamsi,balik_veri$VG_istavrit,alternative = "two.sided",
       paired = FALSE)

# Histogram Değerleri

par(mfrow = c(2,2))

hist(balik_veri$VU_hamsi,xlab = "Sıklık", ylab = " Vucut uzunlugu (cm)",
     main = "Hamsi Vucut uzunlugu")
hist(balik_veri$VU_istavrit,xlab = "Sıklık", ylab = " Vucut uzunlugu (cm)",
     main = "Istavrit Vucut uzunlugu")
hist(balik_veri$VG_istavrit,xlab = "Sıklık", ylab = " Vucut genisligi (cm)",
     main = " Hamsi Vucut genisligi ")
hist(balik_veri$VG_hamsi,xlab = "Sıklık", ylab = "Vucut genisligi (cm)",
     main = "Istavrit Vucut genisligi ")


