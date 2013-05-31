#!/usr/bin/env bash

if [ -z "$HEIRLOOM_INTEGRATION_BUCKET_PREFIX" ]
then
    echo "Set HEIRLOOM_INTEGRATION_BUCKET_PREFIX to run integration data setup."
    echo "This value will be used as the bucket prefix and name."
    exit 1
fi

TMPDIR=`mktemp -d /tmp/heirloom.XXXXXX` || exit 1

heirloom setup -n $HEIRLOOM_INTEGRATION_BUCKET_PREFIX -b $HEIRLOOM_INTEGRATION_BUCKET_PREFIX -e integration -f

echo 'Hello World!' > $TMPDIR/index.html

for i in {1..10}
do
    heirloom upload -n $HEIRLOOM_INTEGRATION_BUCKET_PREFIX -d $TMPDIR -i v$i -e integration
    let "m = $i % 3"
    if [ "$m" == "0" ]
    then
        heirloom tag -n $HEIRLOOM_INTEGRATION_BUCKET_PREFIX -i v$i -a preserve -u true -e integration
    fi
done

rm -rf $TMPDIR


