#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <cephfs|netapp>"
    exit 1
fi

# cache password for cleaning up local cache
echo -n "SUDO password: "
read -s passwd

target=$1

# load FIO module
module load fio

# create output dir
mkdir -p ${target}/out

# hostlist file
hlist=hosts.list

# determin number of hosts used in client-server mode
nhost=$(grep -v -e '^#.*' ${hlist} | wc -l)

# cache flush script
script_cleancache=$(pwd)/../cleancache.sh

for iot in seqr randr; do
    for nj in 1 2 4 8 16; do
        for fs in 1m 2g; do
            fio_job=${target}/${iot}_cs_${fs}.fio
            out_dst=${target}/out/${iot}_${fs}_${nhost}x${nj}.json

            # cleaning local cache
            echo "clean cache ..."
            for h in $(grep -v -e '^#.*' ${hlist}); do
                echo $passwd | ssh $h sudo -S ${script_cleancache}
            done

            echo "sleep for 10 seconds ..."

            sleep 10
             
            echo -n "[$target] IO type=${iot}, job number=${nhost}x${nj}, file size=${fs} ..."

            NJOBS=${nj} fio --client=$hlist $fio_job --output-format=json+ --output=${out_dst}
 
            echo "done"
        done
    done
done
