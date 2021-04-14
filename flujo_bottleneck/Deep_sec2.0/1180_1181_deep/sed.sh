for i in *.snp.rescue.final.annoF; do
    sed -i 's/,/./g'  $i
done

for i in *.snp.rescue.final.annoF; do
    sed -i 's/%/ /g'  $i
done
