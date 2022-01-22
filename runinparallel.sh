#!/usr/bin/env bash
set -e
trap "exit" INT
if [ "$#" -ne 2 ]
then
    echo "Usage: $0 nj hyphenated.txt"
    exit 1
fi
nj=$1
file=$2
fsplit=${file}.
split --number=l/$nj $file $fsplit
for f in ${fsplit}*
do
    cabal run ghc-concurrency-speedup -- -a $f & > /dev/null
done
wait
