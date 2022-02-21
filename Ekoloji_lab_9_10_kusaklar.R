# Burada kullanılacak olan grafikler ggplot2 paketinin yüklenmesini gerektirmektedir.

# ggplot2 paketinin yüklenmesi için

install.packages("ggplot2")

# ggplot2 bir kere yüklendikten sonra yukarıdaki komutu çalıştırmanıza gerek yoktur

# Ancak ggplot2 grafiklerini bulunduğunuz R seansında kullanmadan önce aşağıdaki komutla kütüphaneden yüklemeniz gereklidir.

library(ggplot2)

# İlkin populasyon, fonksiyon içerisine iki argüman almaktadır, örneklem büyüklüğü ve A'nın frekansı
primary <- function(sample_size,freq_A = 0.6){
        freq_a <- 1-freq_A
        population <- data.frame()
        # İlkin populasyon
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

# Kuşaklar boyunca populasyon değişimi fonksiyonu, argümanlar populasyon büyüklüğü ve kuşak sayısı, 1:n
Changing <- function(sample_size,freq_A,generations = 1:5){ 
        population <- primary(sample_size,freq_A)
        for (i in generations){
                generation <- subset(population,Generation == i-1)
                new_pop <- data.frame()
                for (j in 1:sample_size){
                        sample_1 <- unlist(strsplit(as.character(sample(generation$Inds,1)),split =".",fixed = TRUE))
                        sample_2 <- unlist(strsplit(as.character(sample(generation$Inds,1)),split =".",fixed = TRUE))
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

pop_1 <- Changing(30,0.5,1:5)

# Genotip sayılarının değişimi tablosu
table_change <- table(pop_1$Inds,pop_1$Generation)
table_change
# Frekans olarak, /populasyon_büyüklüğü
table_change/30 

#Değişim Grafiği
ggplot(pop_1,aes(x=Generation,fill = Inds)) +
        geom_bar(position = "dodge") +
        xlab("Kuşaklar")+
        ylab("Sayı")+
        scale_fill_grey(start=0.8, end=0.2) +
        scale_x_continuous(breaks=c(0:5))+ # breaks'i kuşak sayısına bağlı olarak değiştirin örn: 10 kuşak için 0:10
        labs(fill = "Genotip") +
        ggtitle("Genotip Frekanslarının Değişimi")

# Allel frekanslarının hesaplanması, fonksiyon argümanları 1.populasyon, 2.kuşak
frequency <- function(pop,generation){
        gen <- subset(pop,Generation == generation)
        freq_A = (2*sum(gen$Inds == "A.A")+sum(gen$Inds == "A.a"))/(2*dim(gen)[1])
        freq_a = (2*sum(gen$Inds == "a.a")+sum(gen$Inds == "A.a"))/(2*dim(gen)[1])
        print(freq_A)
        print(freq_a)
}

# 5. kuşaktaki allel frekansları
frequency(pop_1,5)






