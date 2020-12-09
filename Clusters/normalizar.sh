#!/bin/bash
#Estos comandos solo ayudan a dar formato, cambiamos comas por puntos y eliminamos %
VAR1="cluster"

for i in {02..32}
  do
    VAR2="$VAR1$i"
    echo Ejecutando script en carpeta: "$VAR2"
    cd $VAR2

    for i in *.rescue.final.annoF; do
      sed -i 's/,/./g'  $i
    done

    for i in *.rescue.final.annoF; do
      sed -i 's/%/ /g'  $i
    done

    cd ..

done
