#!/bin/bash
for SIZE in 20G 50G 100G
do
        for BSIZE in 4k 64k 256k 1m 4m 16m
        do
                for NJOBS in 1 2 4 8
                do
                        export SIZE BSIZE NJOBS
                        date
                        echo run fiojob filesize=$SIZE blocksize=$BSIZE njobs=$NJOBS >&2
                        fio randr.fio
                        fio seqr.fio
                        fio seqw.fio    
                done
        done
done
