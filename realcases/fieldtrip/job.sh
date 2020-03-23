#!/bin/bash

module load matlab

cd $PBS_O_WORKDIR

if [ -z $PBS_ARRYAID ] && [ $# -eq 1 ]; then
    export PBS_ARRAYID=$1
fi

# set MATLAB_PREFDIR to local /data folder
export MATLAB_PREFDIR=/data/$PBS_JOBID/$1
mkdir -p $MATLAB_PREFDIR

echo -n "wait "

# wait for start signal to be set in the .start file.
v=$(cat $PBS_O_WORKDIR/.start)
while [[ $v -ne 1 ]]; do
    v=$(cat $PBS_O_WORKDIR/.start)
done
echo

# log timestamp of the start time
date +%s

# run benchmark script
HOME=$MATLAB_PREFDIR matlab -r "mous"

rm -rf /data/$PBS_JOBID
