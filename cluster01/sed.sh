for i in *.DR.snp.final; do
    sed -i 's/,/./g'  $i
done

for i in *.DR.snp.final; do
    sed -i 's/%/ /g'  $i
done
