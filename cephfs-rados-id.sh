#!/bin/bash

for f in $@; do
    inode=$(ls -i $f | awk '{print $1}')
    if [ $? -eq 0 ]; then
        id=$(printf "%x" $inode)
        echo $id $f
    fi
done
