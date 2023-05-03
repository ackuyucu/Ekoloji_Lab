males <- as.character(c(1:50))
females <- as.character(c(50:100))

males <- paste0(males,"m")
females <- paste0(females,"f")

pop <- c(males,females)

pop_1 <- sample(pop,prob = rep(0.8,x = length(pop)))

