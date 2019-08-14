#!/bin/bash

# sleep time between each poll in second
tpause=1

# an infinite loop poll listing objects from the provided pools
while [[ true ]]; do
    now=$(date +%s)
    for p in $@; do
        rados ls -p $p | awk -F '.' '{print $1}' | sort | uniq -c | while read l; do
            echo -n $p $now
            echo $l | awk '{print " "$2,$1}'
        done
    done
    sleep $tpause
done
