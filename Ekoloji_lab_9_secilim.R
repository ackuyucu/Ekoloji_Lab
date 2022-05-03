# Burada kullanılacak olan grafikler ggplot2 paketinin yüklenmesini gerektirmektedir.

# ggplot2 paketinin yüklenmesi için

install.packages("ggplot2")

# ggplot2 bir kere yüklendikten sonra yukarıdaki komutu çalıştırmanıza gerek yoktur

# Ancak ggplot2 grafiklerini bulunduğunuz R seansında kullanmadan önce aşağıdaki komutla kütüphaneden yüklemeniz gereklidir.
library(ggplot2)



# Burada seçilim baskısı altındaki populasyonu simule edeceğiz
# A koyu rengi a ise açık rengi temsil etmekte 

# Öncelikli olarak simulasyonumuz için gerekli fonksiyonları oluşturuyoruz
# İlkin populasyon, fonksiyon içerisine iki argüman almaktadır, örneklem büyüklüğü ve A'nın frekansı
# set seed fonksiyonu oluşturduğunuz random simülasyonu tekrar oluşturmanızı sağlar
set.seed(14)

primary <- function(sample_size,freq_A = 0.1){
        freq_a <- 1-freq_A
        population <- data.frame()
        
        for(i in seq_len(sample_size)){
                ind = sample(c("A","a"),size = 2,replace = TRUE,
                             prob = c(freq_A,freq_a))
                ind_1 = paste(ind[1],ind[2],sep = ".")
                if(ind_1 == "a.A"){ind_1 = "A.a"}
                ind_1 = data.frame("Inds" = ind_1,"Generation" = 0)
                population <- rbind(population,ind_1)
        }
        return(population)
}

#Seçilim fonksiyonu argümanlar populasyon büyüklüğü, üç genotip için seçilim katsayıları vektör olarak örneğin c(1,0.9,0.5)
# Son olarak kuşak sayısı 1:n
Selection <- function(sample_size,freq_A =0.1,sel_coef = c(1,1,1),generations = 1:5){
        population <- primary(sample_size,freq_A)
        for (i in generations){
                generation <- subset(population,Generation == i-1)[,1]
                live_AA <- round(sum(generation == "A.A")*sel_coef[1])
                live_Aa <- round(sum(generation == "A.a")*sel_coef[2])
                live_aa <- round(sum(generation == "a.a")*sel_coef[3])
                generation <- c(rep("A.A",live_AA),rep("A.a",live_Aa),rep("a.a",live_aa))
                new_pop <- data.frame()
                for (j in 1:sample_size){
                        sample_1 <- unlist(strsplit(as.character(sample(generation,1)),split =".",fixed = TRUE))
                        sample_2 <- unlist(strsplit(as.character(sample(generation,1)),split =".",fixed = TRUE))
                        ind <- paste(sample(sample_1,1),sample(sample_2,1),sep =".")
                        if(ind == "a.A"){ind = "A.a"}
                        ind = data.frame("Inds" = ind,"Generation" = i)
                        new_pop <- rbind(new_pop, ind)
                }
                population <- rbind(population, new_pop)
                
        }
        population$Generation <- population$Generation
        return(population)
        
}


# Allel frekanslarının hesaplanması, fonksiyon argümanları 1.populasyon, 2.kuşak
frequency <- function(pop,generation){
  gen <- subset(pop,Generation == generation)
  freq_A = (2*sum(gen$Inds == "A.A")+sum(gen$Inds == "A.a"))/(2*dim(gen)[1])
  freq_a = (2*sum(gen$Inds == "a.a")+sum(gen$Inds == "A.a"))/(2*dim(gen)[1])
  data_freq <- data.frame("A" = freq_A, "a" = freq_a)
  return(data_freq)
  
}

# Kullanacağımız fonksiyonları kodlamayı bitirdik
# Simulasyonların başlangıcı
# Model 1 seçilimin olmadığı bir durumun modellenmesi tüm genotiplerin 
# hayatta kalma olasılığı birbirine eşittir
pop_1 <- Selection(sample_size = 200,
                   freq_A = 0.4,sel_coef = c(1,1,1),generations = 1:5)


# Genotip sayılarının değişim tablosu
table_change <- table(pop_1$Inds,pop_1$Generation)
table_change
# Frekans olarak
table_change/1000

#Değişim Grafiği
ggplot(pop_1,aes(x=Generation,fill = Inds)) +
  geom_bar(position = "dodge") +
  xlab("Kuşaklar")+
  ylab("Sayı")+
  scale_fill_grey(start=0.8, end=0.2) +
  scale_x_continuous(breaks=c(0:5))+    #kuşak sayısına bağlı olarak breaks argümanını değiştirin örneğin 10 küşak için breaks = c(0:10)
  labs(fill = "Genotip") +
  ggtitle("Model 1 Genotip Frekanslarının Değişimi")


# 5. kuşaktaki allel frekansları, A alleli ve a alleli
freq_model_1 <- frequency(pop_1,5)
print(freq_model_1)



# Model 2  endüstri devrimi öncesi koyu renklilere karşı seçilim baskısı
pop_2 <- Selection(sample_size = 200,
                            freq_A = 0.4,sel_coef = c(0.6,0.8,1),generations = 1:5)



# Genotip sayılarının değişim tablosu
table_change <- table(pop_2$Inds,pop_2$Generation)
table_change
# Frekans olarak
table_change/1000




#Değişim Grafiği
ggplot(pop_2,aes(x=Generation,fill = Inds)) +
        geom_bar(position = "dodge") +
        xlab("Kuşaklar")+
        ylab("Sayı")+
        scale_fill_grey(start=0.8, end=0.2) +
        scale_x_continuous(breaks=c(0:5))+    #kuşak sayısına bağlı olarak breaks argümanını değiştirin örneğin 10 küşak için breaks = c(0:10)
        labs(fill = "Genotip") +
        ggtitle("Model 2 Genotip Frekanslarının Değişimi")



# 5. kuşaktaki allel frekansları, A alleli ve a alleli
freq_model_2 <- frequency(pop_2,5)
print(freq_model_2)

# Model 3, endüstri devrimi sonrası artık A alleli lehinde seçilim olduğunu
# modelliyoruz

# Başlangıçtaki A allelinin frekansını bir önceki basamaktan alıyoruz

freq_A <- freq_model_2[1,1]

pop_3 <- Selection(sample_size = 200, freq_A, sel_coef = c(1,0.8,0.6),
                    generations = 1:5)

# Genotip sayılarının değişim tablosu
table_change <- table(pop_3$Inds,pop_3$Generation)
table_change
# Frekans olarak
table_change/1000


# Değişim grafiği Model 3

ggplot(pop_3,aes(x=Generation,fill = Inds)) +
  geom_bar(position = "dodge") +
  xlab("Kuşaklar")+
  ylab("Sayı")+
  scale_fill_grey(start=0.8, end=0.2) +
  scale_x_continuous(breaks=c(0:5))+    #kuşak sayısına bağlı olarak breaks argümanını değiştirin örneğin 10 küşak için breaks = c(0:10)
  labs(fill = "Genotip") +
  ggtitle("Model 3 Genotip Frekanslarının Değişimi")

# 5. kuşaktaki allel frekansları, A alleli ve a alleli
freq_model_3 <- frequency(pop_3,5)
print(freq_model_3)

