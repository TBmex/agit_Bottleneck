for i in *bas.txt; do
    sed -i 's/0.9234567/0.999999/g'  $i
done
