#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 {job_count}"
    exit 1
fi

if [ ! -f hosts.list ]; then
    echo "missing hosts.list file" 1>&2
    exit 2
fi

# read hostlists
hlist=( $(cat hosts.list | grep -v '^#') )

# cleanup compute node cache
script_cleancache=$(pwd)/cleancache.sh
echo -n 'SUDO password: '
read -s pass
for h in "${hlist[@]}"; do
    echo $pass | ssh ${h} sudo -S ${script_cleancache}
done

njobs=$1

## set to hold computation of jobs
echo '0' > .start

## submit jobs
ses=$$
for i in $(seq 1 $njobs); do
    hid=$( echo "$i % ${#hlist[@]}" | bc )
    [ $i -le 195 ] &&
        echo "${PWD}/job.sh $i" | qsub -q tgtest -N bench_mous_${ses}.${i} -l "walltime=20:00,mem=4gb,nodes=${hlist[$hid]}" ||
        echo "${PWD}/job.sh $i" | qsub -q tgtest -N bench_mous_${ses}.${i} -l "walltime=20:00,mem=4gb,nodes=1:ppn=1"
done

## check until all jobs are in R state
echo "wait until all jobs are started before kicking off computation."
c=$(qstat -r | grep bench_${ses} | wc -l)
while [[ $c -lt $njobs ]]; do
    sleep 10
    echo "job started: [$c/$njobs]"
    c=$(qstat -r | grep bench_mous_${ses} | wc -l)
done
echo "job started: [$c/$njobs]"
sleep 30

## information to kick-off computation
echo '1' > .start
echo "computation started."
