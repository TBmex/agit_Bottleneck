# Flujo de trabajo

##Libraris
library(tidyverse)

# Variables
#donor = G76.snp.rescue.final
#receptor = G1180.snp.rescue.final

#donor = G1180.snp.rescue.final
#receptor = G1181.snp.rescue.final

#donor = G0076BottleNeck.snp.rescue.final
#receptor = G1180BottleNeck.snp.rescue.final

donor = G1180BottleNeck.snp.rescue.final
receptor = G1181BottleNeck.snp.rescue.final

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

# Condicionar columnas 1 Y 2
c <- mutate(c, SNPs = ifelse(as.integer(Freq_D * Freq_R) == 0, 2, 1))

# Transformar variable
c$SNPs <- as.factor(c$SNPs)

# Grafico
ggplot(c, aes(x=Freq_D, y=Freq_R, shape=SNPs, color=SNPs)) + 
  geom_point() + geom_smooth(data=c[which(c$SNPs==1),], method=lm)

# Renombramos
Cluster04_Deep <- c

# Borramos archivos intermedios
rm(c, donor, receptor)

# Hacemos joins para ver la sposiciones que ganamos con deep secuencing.
Win04 <- Cluster04_Deep %>% anti_join(Cluster04_NO_deep, by = "Position")
Win10 <- Cluster10_Deep %>% anti_join(Cluster10_NO_deep, by = "Position")

# Realmente ganamos estas posiciones???

Aver <- Win04 %>% inner_join(G1181BottleNeck.snp.rescue.final, by = "Position")
Aver2 <- Win04 %>% inner_join(G1180BottleNeck.snp.rescue.final, by = "Position")
Aver3 <- Aver %>% full_join(Aver2, by = "Position")




