# Gerekli kütüphanelerin yüklenmesi
# tidyverse; ggplot2, dplyr ve diğer faydalı veri işleme araçlarını içerir
library(tidyverse)

# Tekrarlanabilirlik için başlangıç değerini (seed) ayarlama
set.seed(14)

# 1. Başlangıç Populasyonu Fonksiyonu
# İlk kuşağı (0. Kuşak) oluşturur
primary <- function(sample_size, freq_A = 0.1) {
  freq_a <- 1 - freq_A
  
  # Verimlilik için vektörize edilmiş örneklem alma
  alleles1 <- sample(c("A", "a"), size = sample_size, replace = TRUE, prob = c(freq_A, freq_a))
  alleles2 <- sample(c("A", "a"), size = sample_size, replace = TRUE, prob = c(freq_A, freq_a))
  
  # Allelleri birleştirme ve heterozigot gösterimini "A.a" olarak standartlaştırma
  inds <- paste(alleles1, alleles2, sep = ".")
  inds[inds == "a.A"] <- "A.a"
  
  population <- data.frame(Inds = inds, Generation = 0, stringsAsFactors = FALSE)
  return(population)
}

# 2. Seçilim Fonksiyonu
# Belirli seçilim katsayıları altında kuşakları simüle eder
Selection <- function(sample_size, freq_A = 0.1, sel_coef = c(1, 1, 1), generations = 1:5) {
  # Başlangıç populasyonu ile başlama
  population <- primary(sample_size, freq_A)
  
  for (i in generations) {
    # Bir önceki kuşağı çıkarma
    prev_gen <- subset(population, Generation == i - 1)$Inds
    
    # Seçilim katsayılarına göre hayatta kalanları hesaplama
    live_AA <- round(sum(prev_gen == "A.A") * sel_coef[1])
    live_Aa <- round(sum(prev_gen == "A.a") * sel_coef[2])
    live_aa <- round(sum(prev_gen == "a.a") * sel_coef[3])
    
    # Hayatta kalanlardan çiftleşme havuzu oluşturma
    survivors <- c(rep("A.A", live_AA), rep("A.a", live_Aa), rep("a.a", live_aa))
    
    # Hayatta kalanlar havuzundan tüm bireysel allelleri çıkarma
    allele_pool <- unlist(strsplit(survivors, split = ".", fixed = TRUE))
    
    # Bir sonraki kuşağı üretmek için rastgele çiftleştirme
    new_alleles1 <- sample(allele_pool, size = sample_size, replace = TRUE)
    new_alleles2 <- sample(allele_pool, size = sample_size, replace = TRUE)
    
    new_inds <- paste(new_alleles1, new_alleles2, sep = ".")
    new_inds[new_inds == "a.A"] <- "A.a"
    
    new_pop <- data.frame(Inds = new_inds, Generation = i, stringsAsFactors = FALSE)
    
    # Ana populasyon veri çerçevesine (dataframe) ekleme
    population <- rbind(population, new_pop)
  }
  return(population)
}

# 3. Allel Frekansı ve Sayım Fonksiyonu
# Hem frekansları hem de kesin sayıları hesaplar (istatistiksel testler için gereklidir)
get_allele_stats <- function(pop, generation) {
  gen_data <- subset(pop, Generation == generation)
  n_individuals <- nrow(gen_data)
  
  count_A <- (2 * sum(gen_data$Inds == "A.A")) + sum(gen_data$Inds == "A.a")
  count_a <- (2 * sum(gen_data$Inds == "a.a")) + sum(gen_data$Inds == "A.a")
  
  total_alleles <- 2 * n_individuals
  
  list(
    counts = c(A = count_A, a = count_a),
    frequencies = data.frame(A = count_A / total_alleles, a = count_a / total_alleles)
  )
}

# 4. Grafik Çizim Fonksiyonu
# Herhangi bir model için renkli grafikler oluşturmaya yarayan yeniden kullanılabilir bir fonksiyon
plot_population <- function(pop_data, title) {
  ggplot(pop_data, aes(x = Generation, fill = Inds)) +
    geom_bar
