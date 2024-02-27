rep_data <- read.csv("c:/Work_space/work/HU_research/kertenkele/last_data/Analiz/rep_data_son.csv",header = TRUE)
rep_data$Substrate <- as.factor(rep_data$Substrate)



par(mfrow = c(1,1))
with(rep_data, hist(Body_temp,xlab = "Body Temperature",ylab = "Frequency",main = "",col = "red",breaks = 30))
title(main = "Histogram of Body Temperature")
rug(rep_data$Body_temp)




# Using subset to plot different categories
with(rep_data,plot(Body_temp,Solar_rad,main = "",type = "n"))
with(subset(rep_data,Species == "Lacerta_trilineata"),points(Body_temp,Solar_rad,col = "blue"))
with(subset(rep_data,Species == "Parvilacerta_parva"),points(Body_temp,Solar_rad,col = "red"))

#Changing point type,Inserting lines to plot and changing linetype 

with(rep_data, boxplot(Body_temp~Species,col = "red"))
abline(h = mean(rep_data$Body_temp),lwd = 3,lty = 2, col = "blue")


with(rep_data,plot(Ts,Body_temp,main = "",pch = 1,col = "blue",
                   xlab = "Substrate Temperature", ylab = "Body Temperature"))
model <- lm(Body_temp~Ts,data = rep_data)
abline(model,lwd = 2,lty = 1,col = "black")


# More than one plots
#First plot
par(mar = c(4,3,3,2))
par(mfrow = c(2,1))

with(rep_data, hist(Body_temp,xlab = "Body_Temperature",ylab = "Frequency",main = "",col = "red"))
title(main = "Histogram of Body Temperature")

with(rep_data,boxplot(Body_temp~Species,col = "blue"))
title(main = "Boxplots for Body Temperature")

# Multiple plots

par(mfrow = c(2, 2), mar = c(4, 4, 2, 1), oma = c(0, 0, 2, 0))
with(rep_data, {
  plot(Ta,Ts , main = "Ta and Ts")
  plot(Solar_rad, Body_temp, main = "Solar rad. and Body Temperature")
  plot(Solar_rad,Tex , main = "Solar rad. and Temp. excess")
  mtext("Thermal Biology Plots", outer = TRUE)
})


#Additional plots, annotations including legends

library(datasets)
#1
par(mfrow = c(1,1),mar = c(4,4,2,1))
with(airquality, plot(Wind, Ozone))
title(main = "Ozone and Wind in New York City") ## Add a title
#2
with(airquality, plot(Wind, Ozone, main = "Ozone and Wind in New York City"))
with(subset(airquality, Month == 5), points(Wind, Ozone, col = "blue"))

#3
with(airquality, plot(Wind, Ozone, main = "Ozone and Wind in New York City",
                      type = "n"))

#4
with(subset(airquality, Month == 5), points(Wind, Ozone, col = "blue"))
with(subset(airquality, Month != 5), points(Wind, Ozone, col = "red"))
legend("topright", pch = 1,cex = 0.75, col = c("blue", "red"), legend = c("May", "Other Months"))

#5 Regression line

with(airquality, plot(Wind, Ozone, main = "Ozone and Wind in New York City",
                      pch = 20))
model <- lm(Ozone ~ Wind, airquality)
abline(model, lwd = 2)


# Multiple plots

par(mfrow = c(1, 2))
with(airquality, {
  plot(Wind, Ozone, main = "Ozone and Wind")
  plot(Solar.R, Ozone, main = "Ozone and Solar Radiation")
})

par(mfrow = c(1, 3), mar = c(4, 4, 2, 1), oma = c(0, 0, 2, 0))
with(airquality, {
  plot(Wind, Ozone, main = "Ozone and Wind")
  plot(Solar.R, Ozone, main = "Ozone and Solar Radiation")
  plot(Temp, Ozone, main = "Ozone and Temperature")
  mtext("Ozone and Weather in New York City", outer = TRUE)
})



