#!/bin/bash
JF=$1
LCOUNT=$4
TMPDIR=$5

if [ "$#" -eq "4" ];
then
$JF count -m $3 -o $TMPDIR/jf_tmp -c 3 -s 10000000 -t 32 --canonical $6
else
$JF count -m $3 -o $TMPDIR/jf_tmp -c 3 -s 10000000 -t 32 --canonical $6 $7
fi;

# merge
N_TMP=`ls -1 $TMPDIR/jf_tmp* | wc -l`
if [ $N_TMP -eq 1 ]
then
    mv $TMPDIR/jf_tmp $TMPDIR/jf_merged_$3
else
    $JF merge $TMPDIR/jf_tmp* -o $TMPDIR/jf_merged_$3
    rm $TMPDIR/jf_tmp_*
fi

$JF dump --lower-count=$LCOUNT -o $2 -c $TMPDIR/jf_merged_$3
rm $TMPDIR/jf_merged_$3
