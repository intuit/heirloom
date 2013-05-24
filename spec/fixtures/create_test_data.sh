#!/usr/bin/env bash

TMPDIR=`mktemp -d /tmp/heirloom.XXXXXX` || exit 1
NAME=test_data

heirloom setup -n $NAME -b heirloom-integration-tests -e integration -f

echo 'Hello World!' > $TMPDIR/index.html

for i in {1..10}
do
    heirloom upload -n $NAME -d $TMPDIR -i v$i -e integration
    let "m = $i % 3"
    if [ "$m" == "0" ]
    then
        heirloom tag -n $NAME -i v$i -a preserve -u true -e integration
    fi
done

rm -rf $TMPDIR


