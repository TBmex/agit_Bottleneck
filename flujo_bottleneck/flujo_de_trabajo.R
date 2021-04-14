# Flujo de trabajo

##Libraris
library(tidyverse)

# Variables
donor = G1180BottleNeck.snp.rescue.final
receptor = G1181BottleNeck.snp.rescue.final

# Extraer columnas Position y VarFreq
donor <- donor[c(2,7)]
receptor <- receptor[c(2,7)]

# Renombrar columnas
names(donor)=c("Position","Freq_D")
names(receptor)=c("Position","Freq_R")

# Join / merge
c<-merge (donor, receptor, by = "Position", all.x=TRUE, all.y=TRUE)

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
Cluster10_deep <- c

# Borramos archivos intermedios
rm(c, donor, receptor)
#Snps_deep <- c %>% filter(Freq_D < 90, Freq_R < 90)
#Snps_normal <- c10 %>% filter(VarFreq.y < 90, VarFreq.y < 90)

#Menoresde25_deep <- c %>% filter(Freq_D < 25, Freq_R < 25)
#Menoresde25_normal <- c10 %>% filter(VarFreq.x < 25, VarFreq.y < 25)