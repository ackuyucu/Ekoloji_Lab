# Olasılık hesaplamaları

# Bir uygulamanın tavuklarda yumurtlama sonrasında eşey oranını etkisini araştırıyoruz. 
# 48 yumurtanın açılması sonucu, dişi : erkek sayıları.

# Bunun için binom fonksiyonları kullanılabilir
# İlk olarak 23:25 olasılıklarını düşünelim
# q = 50 yumurtanın içinden açılanların dişi ya da erkek olması
# size toplam açılan yumurta sayısı

pbinom(q = 20,size = 50,prob = 0.5,lower.tail = TRUE)

dbinom(x = 25,prob = 0.5,size = 50)

egg_probs <- data.frame()

for(i in 0:50){
        Prob = data.frame("Prob"= dbinom(x = i,prob = 0.5,size = 50),"Eggs" = i)
        egg_probs <- rbind(egg_probs,Prob)
        
}

barplot(height = egg_probs$Prob,main = "Yumurta Dişi/Erkek Olasılıkları",
        ylab = "Olasılıklar",xlab="Yumurta Sayıları",names = egg_probs$Eggs,
        col = ifelse(egg_probs$Eggs <= 23,'red','grey'))

