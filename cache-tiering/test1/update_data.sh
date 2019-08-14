#!/bin/bash

cat files.txt | while read l; do
    obj=$(echo $l | awk '{print $1}')
    fn=$(echo $l | awk '{print $2}')
    for f in *_count.dat; do
        sed -i "s/${obj}/${fn}/g" $f
    done
done
