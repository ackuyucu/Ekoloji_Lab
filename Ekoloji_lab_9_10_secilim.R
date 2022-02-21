# Burada seçilim baskısı altındaki populasyonu simule edeceğiz

library(ggplot)
# İlkin populasyon, fonksiyon içerisine iki argüman almaktadır, örneklem büyüklüğü ve A'nın frekansı
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
Selection <- function(sample_size,freq_A =0.1,sel_coef = c(1,0.8,0.5),generations = 1:5){
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

pop_1 <- Selection(sample_size = 1000,
                            freq_A = 0.8,sel_coef = c(1,0.8,0.6),generations = 1:5)


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
