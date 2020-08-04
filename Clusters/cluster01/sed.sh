for i in *.rescue.final.annoF; do
    sed -i 's/,/./g'  $i
done

for i in *.rescue.final.annoF; do
    sed -i 's/%/ /g'  $i
done
