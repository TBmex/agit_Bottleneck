#los argumentos serán 1. el arhivo .snp que se desea filtrar (se ha creado para filtrar los DR que utiliza carlos en sus análisis de bottlenceck) y el 2 el archivo .indel (no tenemos acceso a los pileups pero creo que con esto ser puede hacer sin problema),

# para ejecutar Rscript 2_1_filtering_MODIFICADO.R $FILE.DR.snp.final $FILE.snp.indel -window_density 10 -window_indel 0 -output $FILE.snp.final 

 

args=commandArgs(trailingOnly = TRUE)

print(args[1])

tabla<- read.delim(args[1], stringsAsFactors=FALSE)

indel <- read.delim(args[2], stringsAsFactors=FALSE)

#pileup_indel <- read.delim(args[3], stringsAsFactors=FALSE, header = FALSE)

bp_del=NULL

bp_den=NULL

files=NULL

for (i in 1:length(args))

{

  if (grepl("-window_density",args[i])) {bp_den=as.numeric(args[i+1])}

  if (grepl("-window_indel",args[i])) {bp_del=as.numeric(args[i+1])}

  if (grepl("-output",args[i])) {files=args[i+1]}

}

if (is.null(bp_den)) {bp_den=10}

if (is.null(bp_del)) {bp_del=10}

indel_regions=cbind(indel[,2],indel[,2])

for (i in 1:dim(indel_regions)[1]){

  if (grepl("[+]",as.character(indel[i,4]))) {indel_regions[i,2]=indel_regions[i,2]+(nchar(as.character(indel[i,4]))-3)} #las inserciones, defino la ventana como pos-10 y pos+tamaño del_dens inserto+10

}

#indel_regions=rbind(indel_regions,pileup_indel)

#indel_regions=indel_regions[order(indel_regions[,1]),]

setwdaux_dens=NULL

aux_indel=NULL

del_dens=NULL

del_indel=NULL

for (i in 1:dim(tabla)[1]) { #compruebo que no haya SNPs muy cerca unos de otros. 

  aux_dens=which(tabla[-i,2]<=tabla[i,2]+bp_den & tabla[-i,2]>=tabla[i,2]-bp_den)

  if (length(aux_dens)>2) {del_dens=c(del_dens,aux_dens)}

  del_dens=unique(del_dens)

}

if (!is.null(del_dens) & length(del_dens)>0) { 

		print(paste(length(del_dens)," SNPS found in density test (",bp_den,"bp window )"))

    tabla=tabla[-del_dens,]

} else { 

   print(paste("No SNPs found in density test (",bp_den,"bp window)"))

}

for (i in 1:dim(indel_regions)[1]) { #compruebo que no haya SNPs cerca de las zonas de INDEL 

  aux_indel=which(tabla[,2]>=(indel_regions[i,1]-bp_del) & tabla[,2]<=(indel_regions[i,1]+bp_del)) 

  del_indel=c(del_indel,aux_indel)

  del_indel=unique(del_indel)

}

if (!is.null(del_indel)& length(del_indel)>0) { 

  print(paste(length(del_indel)," SNPS found near INDEL areas (",bp_del,"bp window )"))

  tabla=tabla[-del_indel,]

  write.table(tabla,sep="\t",quote=FALSE,row.names=FALSE, file=files)

} else { 

  print(paste("No SNPs found near INDEL areas (",bp_del,"bp window)"))

  write.table(tabla,sep="\t",quote=FALSE,row.names=FALSE, file=files)

}
