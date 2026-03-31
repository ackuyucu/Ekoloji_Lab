# Genetik Sürüklenme

# Gerekli kütüphanelerin yüklenmesi
library(tidyverse)

# Tekrarlanabilirlik için
set.seed(42)

# Sürüklenme ve Akrabalı Yetiştirme Simülasyon Fonksiyonu
# N: Populasyon büyüklüğü (Birey sayısı)
# p0: Başlangıçtaki 'A' allelinin frekansı
# F_coeff: Akrabalı yetiştirme katsayısı (0 = rastgele çiftleşme, 1 = tam akrabalı yetiştirme)
# generations: Simüle edilecek kuşak sayısı
# replicates: Sürüklenmenin şans faktörünü görmek için simüle edilecek farklı populasyon sayısı
simulate_drift_inbreeding <- function(N, p0, F_coeff = 0, generations = 50, replicates = 10) {
  
  # Sonuçları depolamak için boş bir veri çerçevesi (dataframe)
  results <- data.frame()
  
  for (rep in 1:replicates) {
    p <- p0 # Her kopya populasyon başlangıç frekansıyla başlar
    
    for (gen in 0:generations) {
      q <- 1 - p
      
      # Akrabalı yetiştirme katsayısı (F) dahil edilerek beklenen genotip frekanslarının hesaplanması
      # Formül: f(AA) = p^2 + Fpq, f(Aa) = 2pq(1-F), f(aa) = q^2 + Fpq
      prob_AA <- (p^2) + (F_coeff * p * q)
      prob_Aa <- (2 * p * q) * (1 - F_coeff)
      prob_aa <- (q^2) + (F_coeff * p * q)
      
      # Olasılıkların negatif olmasını önleme (yuvarlama hatalarına karşı güvenlik önlemi)
      probs <- pmax(c(prob_AA, prob_Aa, prob_aa), 0)
      probs <- probs / sum(probs) # Olasılıkların toplamının 1 olduğundan emin olma
      
      # Genotipleri örnekleme (Sürüklenme tam olarak burada gerçekleşir, çünkü N sınırlıdır)
      sampled_genotypes <- sample(
        c("AA", "Aa", "aa"), 
        size = N, 
        replace = TRUE, 
        prob = probs
      )
      
      # Gözlenen genotip sayıları
      n_AA <- sum(sampled_genotypes == "AA")
      n_Aa <- sum(sampled_genotypes == "Aa")
      n_aa <- sum(sampled_genotypes == "aa")
      
      # Gözlenen Heterozigotluk
      obs_het <- n_Aa / N
      # Beklenen Heterozigotluk (Hardy-Weinberg varsayımı ile, F = 0 olsaydı)
      exp_het <- 2 * p * q
      
      # Bir sonraki kuşak için yeni p allel frekansını hesaplama
      p_new <- ( (2 * n_AA) + n_Aa ) / (2 * N)
      
      # Verileri kaydetme
      results <- rbind(results, data.frame(
        Replicate = as.factor(rep),
        Generation = gen,
        Freq_A = p,
        Obs_Het = obs_het,
        Exp_Het = exp_het
      ))
      
      # Bir sonraki döngü için frekansı güncelleme
      p <- p_new
      
      # Eğer allel sabitlenir (1) veya kaybolursa (0), frekans değişmeden kalır
      if(p == 0 | p == 1) {
        p <- round(p) 
      }
    }
  }
  return(results)
}

# ==========================================
# SİMÜLASYONLAR
# ==========================================

# Senaryo 1: Küçük populasyon (N=50), Akrabalı yetiştirme yok (F=0) -> Sadece Sürüklenme
sim_drift_only <- simulate_drift_inbreeding(N = 50, p0 = 0.5, F_coeff = 0, generations = 50, replicates = 10)

# Senaryo 2: Küçük populasyon (N=50), Yüksek akrabalı yetiştirme (F=0.5) -> Sürüklenme + Akrabalı Yetiştirme
sim_drift_inbreeding <- simulate_drift_inbreeding(N = 50, p0 = 0.5, F_coeff = 0.5, generations = 50, replicates = 10)


# ==========================================
# GÖRSELLEŞTİRME
# ==========================================

# Grafik 1: Genetik Sürüklenme (Allel Frekanslarının Zaman İçindeki Rastgele Hareketi)
plot_drift <- ggplot(sim_drift_only, aes(x = Generation, y = Freq_A, color = Replicate)) +
  geom_line(alpha = 0.8, linewidth = 1) +
  scale_y_continuous(limits = c(0, 1)) +
  scale_color_viridis_d() +
  labs(
    title = "Genetik Sürüklenme (N = 50, F = 0)",
    subtitle = "Farklı populasyonlarda A allelinin zaman içindeki rastgele değişimi",
    x = "Kuşaklar",
    y = "'A' Alleli Frekansı (p)"
  ) +
  theme_minimal() +
  theme(legend.position = "none", text = element_text(size = 12))

print(plot_drift)

# Grafik 2: Akrabalı Yetiştirmenin Heterozigotluk Üzerindeki Etkisi
# Bu grafik için Replicate'lerin ortalamasını alıyoruz
summary_het <- sim_drift_inbreeding %>%
  group_by(Generation) %>%
  summarize(
    Mean_Obs_Het = mean(Obs_Het),
    Mean_Exp_Het = mean(Exp_Het)
  ) %>%
  pivot_longer(cols = c(Mean_Obs_Het, Mean_Exp_Het), names_to = "Metric", values_to = "Value") %>%
  mutate(Metric = ifelse(Metric == "Mean_Obs_Het", "Gözlenen Heterozigotluk (F=0.5)", "Beklenen Heterozigotluk (HW)"))

plot_het <- ggplot(summary_het, aes(x = Generation, y = Value, color = Metric, linetype = Metric)) +
  geom_line(linewidth = 1.2) +
  scale_color_manual(values = c("black", "firebrick")) +
  scale_y_continuous(limits = c(0, 0.6)) +
  labs(
    title = "Akrabalı Yetiştirme Etkisi (N = 50, F = 0.5)",
    subtitle = "Gözlenen heterozigotluk, beklenen HW değerinin sistematik olarak altındadır",
    x = "Kuşaklar",
    y = "Ortalama Heterozigotluk"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom", legend.title = element_blank(), text = element_text(size = 12))

print(plot_het)
