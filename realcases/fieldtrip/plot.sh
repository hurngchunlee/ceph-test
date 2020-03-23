#!/bin/bash

function gen_data() {
    echo "nj <- c()"
    echo "avg <- c()"
    echo "std <- c()"
    echo "sys <- c()"

    for sys in cephfs netapp; do
        for nj in 1 2 4 8 16 32 64 120 128 150 180 204; do
            ls ${sys}/${nj}/*.o* >/dev/null 2>&1 &&
            echo "nj <- c(nj, $nj)" &&
            echo "speed <- c($(grep 'READING SPEED' ${sys}/${nj}/*.o* | awk 'BEGIN{ORS=","}{print $(NF-1)}' | sed 's/,$//g'))" &&
            echo "avg <- c(avg, mean(speed))" &&
            echo "std <- c(std, sd(speed))" &&
            echo "sys <- c(sys, '${sys}')"
        done
    done

    echo "data <- data.frame(nj,sys,avg,std)"
    echo "save(data, file='speed.Rdata')"
    echo "print(data)"
}

module load R
gen_data > data.R && Rscript data.R && Rscript plot.R

# cleanup intermediate files
[ -f data.R ] && rm -f data.R
