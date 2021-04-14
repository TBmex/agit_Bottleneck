#!/bin/bash

#primero se filtran los archivos .DR, vamos a eliminar todas las posiciones con menos de 20 lecturas

FILES=$(ls *.DR.snp.final | cut -d"." -f1)

for FILE in $FILES
do
 awk '(NR == 1) || ($6 >= 20)' $FILE.DR.snp.final > $FILE.filter20
done	

# en este segundo paso se recogen todas las posiciones comunes y no comunes de los archivos filtrados
for FILE in $FILES
 do
  awk 'NR >1 {print $2}' $FILE.filter20 >> positions
 done
sort -hu positions > filtered.positions
rm positions

# con awk vamos a buscar todas las posiciones comunes y filtradas (filtered.positions) en los archivos .snp, es como hacer el rescate que se hace en el multifasta, pero para cada archivo
for FILE in $FILES
 do
  awk 'NR==1  {print $0}' $FILE.snp > header
  awk '(NR == 1) || NR==FNR{a[$1]++;next}a[$2]'  filtered.positions $FILE.snp  > $FILE.temp
  cat header $FILE.temp > $FILE.snp.rescue
  rm header
  rm $FILE.temp
 done

#ahora hacemos el filtrado por densidad con el script que ya teníamos, aquí tienes que definir dónde vas a tener el script y modificar la ruta
ls *.snp.rescue | cut -d"." -f1 |
  xargs -P 1 -I {} Rscript /data2/EPI_valencia/Mariana_test/2_1_filtering_modificado.R {}.snp.rescue {}.snp.indel -window_density 10 -window_indel 0 -output {}.snp.rescue.final


#voy a filtrar por anotación los archivos que generé (los *.snp.rescue.final)
ls *.snp.rescue.final | xargs -I {} -P 1 ThePipeline annotation_filter -s {}



#rm filtered.positions
#rm *.filter20
#rm *.snp.rescue
#rm *.snp.rescue.final
