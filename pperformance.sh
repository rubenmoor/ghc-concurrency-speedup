set -e
trap "exit" INT
if [ "$#" -ne 2 ]
then
    echo "Provide the maximum number of jobs as first argument,"
    echo "and -a|-s as second argument to select \`Async\` or \`scheduler\`"
    echo "E.g.: $0 12 -a"
    exit 1
fi
maxnj=$1
conclib=$2
cabal build --ghc-options="-threaded"
for nlines in 10000 100000
do
    echo "$nlines"
    head -n $nlines < hyphenated.txt > hyphenated-h${nlines}.txt

    for nj in $(seq 1 $maxnj)
    do
        /usr/bin/env time -f %e \
            cabal run --ghc-options="-threaded" ghc-concurrency-speedup \
                -- $conclib hyphenated-h${nlines}.txt \
                   +RTS -N$nj \
            > /dev/null
    done

    rm hyphenated-h${nlines}.txt
done
