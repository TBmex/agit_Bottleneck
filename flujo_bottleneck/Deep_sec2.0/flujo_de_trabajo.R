# Flujo de trabajo

##Libraris
library(tidyverse)

# Variables

# Cluster10_NO_Deep
donor = G76.snp.rescue.final
receptor = G1180.snp.rescue.final

# Cluster04_NO_Deep
#donor = G1180.snp.rescue.final
#receptor = G1181.snp.rescue.final

# Cluster10_Deep
#donor = G0076BottleNeck.snp.rescue.final
#receptor = G1180BottleNeck.snp.rescue.final

# Cluster04_Deep
#donor = G1180BottleNeck.snp.rescue.final
#receptor = G1181BottleNeck.snp.rescue.final

# Extraer columnas Position y VarFreq
donor <- donor[c(2,7)]
receptor <- receptor[c(2,7)]

# Renombrar columnas
names(donor)=c("Position","Freq_D")
names(receptor)=c("Position","Freq_R")

# Join / merge
c <- donor %>% full_join(receptor)

# Cambiar NAs
c <- c %>% replace_na(list(Freq_D = 0, Freq_R = 0))

# Condicionar columnas 1 = esta en ambos y 2 = solo esta en uno
c <- mutate(c, SNPs = ifelse(as.integer(Freq_D * Freq_R) == 0, 2, 1))

# Transformar variable
c$SNPs <- as.factor(c$SNPs)

# Grafico
ggplot(c, aes(x=Freq_D, y=Freq_R, shape=SNPs, color=SNPs)) + 
  geom_point() + geom_smooth(data=c[which(c$SNPs==1),], method=lm)

# Renombramos
Cluster10_NO_Deep <- c
#Cluster04_NO_Deep <- c
#Cluster10_Deep <- c
#Cluster04_Deep <- c

# Borramos archivos intermedios
rm(c, donor, receptor)

# Hacemos joins para ver la sposiciones que ganamos con deep secuencing.
Win04 <- Cluster04_Deep %>% anti_join(Cluster04_NO_Deep, by = "Position")
Win10 <- Cluster10_Deep %>% anti_join(Cluster10_NO_Deep, by = "Position")

# Realmente ganamos estas posiciones???

Ganadas1180 <- Win04 %>% inner_join(G1180BottleNeck.snp.rescue.final, by = "Position")
Ganadas1181 <- Win04 %>% inner_join(G1181BottleNeck.snp.rescue.final, by = "Position")

Ganadas1180_0 <- Ganadas1180 %>% select(Position, Freq_D, Freq_R, SNPs, Ref, Cons, VarAllele)
Ganadas1181_0 <- Ganadas1181 %>% select(Position, Freq_D, Freq_R, SNPs, Ref, Cons, VarAllele)

Aver3 <- Ganadas1180_0 %>% full_join(Ganadas1181_0)






