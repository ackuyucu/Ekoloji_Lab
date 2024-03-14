# Temel işlemler

3 + 2

3 - 1

3 * (4 - 1)

4^0.5

# öncelik sırası: ) , ^ , * ya da / , + ya da -

x <- 1
print(x)

msg <- "Merhaba!"  ## Mesaj için kullanılır

# Atama

x <- 5 ## ekrana bir şey çıkmaz

x  # Otomatik olarak yazılır

print(x)

# Vektör serisi

x <- 11:20
x

# Elemanlara erisim

x[1]

x[3:6]

# Vektör işlemleri

x + 4

x - 5

x * 10

x / 10

log(x)

exp(x)

y <- 21:30

x + y 

x / y


y <- 3:6

x + y # ?


y <- 4:5

x + y

# Kalıcı değişim

x

x <- x - 3

x

# Logic (mantik) operasyonlari

3 < 4

3 > 10

x

x > 15 

over_15 <- (x == 15)

x != 15

# Çeşitli Vektörler

x <- c("Hi",0.5,0.6) #numerik
x <- c(TRUE,FALSE) # logical (mantık)
x <- c(T,F) #logical
x <- c("a","b","c") ## karakter
x <- 9:29 ## tam sayı
x <- c(1+0i,2+4i) ## karmaşık sayı

# Boş vektör
x <- vector("numeric",length = 10)
x


# Karışık listeler, otomatik dönüşüm

y <- c(1.7,"a") ## karakter
y <- c(TRUE,2) ## ?
y <- c("a",TRUE) ## ?

# Donusturme

x <- 0:6
class(x)
as.numeric(x)
as.logical(x)
as.character(x)

x <- c("a","b","c")
as.numeric(x)
as.logical(x)
as.complex(x)


# Matrisler

m <- matrix(nrow = 2, ncol= 3)
m
dim(m)
attributes(m)

m <- matrix(1:6,nrow = 2,ncol = 3, byrow = TRUE)
m <- matrix(1:9,nrow=3,ncol= 3)

m <- 1:10
m

dim(m) <- c(2,5)
m

# Sütun yapıştırma

x <- 1:3
y <- 10:12
cbind(x,y)
rbind(x,y)

x <- list(1,"a",TRUE,1 + 4i)
x

x <- vector("list",length = 5)

# Faktörler (kategorik)

x <- factor(c("yes","yes","no","yes","no"))
table(x)

unclass(x)

x <- factor(c("yes","yes","no","yes","no"), levels = c("no","yes"))



# Names

x <- 1:3
names(x)

names(x) <- c("A1","B2","C3")

# Naming lists

x <- list("Ankara" = 1, "Izmir" = 2, "Adana" = 3)
x

# İsimlendirme

m <- matrix(1:4,nrow = 2,ncol = 2)

dimnames(m) <- list(c("a","b"),c("c","d"))

m

colnames(m) <- c("h", "f")

rownames(m) <- c("x", "z")

m

# Dataframe (Veri Çerçeveleri)

data1 <- data.frame(foo = 1:4,bar = c(TRUE,TRUE,FALSE,FALSE))

data1

# Örnek paket yükleme

install.packages("datasets")

# Hazır veri setleri

library(datasets)


iris_data <- iris


# Veri ozeti

head(iris_data)

summary(iris_data)

names(iris_data)

iris_data$Sepal.Width

# Veri secimi

iris_data$Sepal.Length[1:6]

iris_data[1:6,1]

iris_data[1:6,2:4]


#  NA degerleri kayip veriler

x <- c(1, 2, NA, 4, NA, 5)

na.omit(x)

bad <- is.na(x)

bad

x[!bad]

x <- x[!bad]


airquality

bad <- is.na(airquality)

air_new <- airquality[!bad]

# Dosya okuma

getwd()

setwd("Data/")

setwd("../")

Bytho <- read.csv("Data/Bytho.csv")

head(Bytho)

# Paket yükleme

install.packages("tidyverse", dependencies = T)
