#!/bin/bash

VAR1="CL"

for i in {05,08,10,31,78}
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
