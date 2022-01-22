set -e
trap "exit" INT
if [ "$#" -ne 1 ]
then
    echo "Provide the maximum number of jobs as argument"
    echo "E.g.: $0 12"
    exit 1
fi
maxnj=$1
cabal build

for nlines in 10000 100000
do
    echo "$nlines"
    f=hyphenated-h${nlines}.txt
    head -n $nlines < hyphenated.txt > $f
    for nj in $(seq 1 $maxnj)
    do
        /usr/bin/env time -f %e ./runinparallel.sh $nj $f > /dev/null
        rm ${f}.*
    done
    rm $f
done
