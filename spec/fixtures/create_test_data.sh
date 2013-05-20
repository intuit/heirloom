#!/usr/bin/env bash

TMPDIR=`mktemp -d /tmp/heirloom.XXXXXX` || exit 1
NAME=test_data

heirloom setup -n $NAME -b heirloom-test-data

echo 'Hello World!' > $TMPDIR/index.html

for i in {1..10}
do
    heirloom upload -n $NAME -d $TMPDIR -i v$i
    let "m = $i % 3"
    if [ "$m" == "0" ]
    then
        heirloom tag -n $NAME -i v$i -a preserve -u true
    fi
done

rm -rf $TMPDIR


