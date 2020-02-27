#!/bin/bash

function json2csv() {
    out=$1

    raw=$( cat $out | grep -v 'fio: output file open error' )

    # IO file size
    fsize=$( echo $raw | ../jq '."global options".filesize' | sed 's/"//g' )

    # IO block size
    bs=$( echo $raw | ../jq '.client_stats | map(select(.jobname != "All clients"))[1] | ."job options".bs' | sed 's/"//g' )

    # number of jobs 
    nj=$( echo $raw | ../jq '.client_stats | map(select(.jobname != "All clients"))[1] | ."job options".numjobs' | sed 's/"//g' )

    # number of hosts
    nh=$( echo $raw | ../jq '.client_stats | map(select(.jobname != "All clients"))[] | .hostname' | sort | uniq | wc -l )

    # total number of jobs
    nj_total=$( echo "$nj * $nh" | bc )

    iot=$( echo $( basename $out ) | awk -F '_' '{print $1}' )
    case $iot in

    seqr|randr)
        data=$( cat $out | grep -v 'fio: output file open error' | ../jq '.client_stats[] | select(.jobname == "All clients") | .read') 
        ;;
    seqw|randw)
        data=$( cat $out | grep -v 'fio: output file open error' | ../jq '.client_stats[] | select(.jobname == "All clients") | .write') 
        ;;
    *)
        data='{}'
        ;;
    esac
    
    bw=$( echo $data | ../jq '.bw' )
    iops=$( echo $data | ../jq '.iops' )
    lat_mean_ns=$( echo $data | ../jq '.lat_ns.mean' )
    lat_stdv_ns=$( echo $data | ../jq '.lat_ns.stddev' )

    echo ${iot},${fsize},${bs},${nj},${nh},${nj_total},${bw},${iops},${lat_mean_ns},${lat_stdv_ns}
}

if [ $# -lt 1 ]; then
    echo "Usage: $0 <cephfs|netapp>"
    exit 1
fi

target=$1

# CSV header
echo 'sys,iotype,fsize,bsize,n_jobs,n_hosts,n_jobs_total,bwidth,iops,lat_mean_ns,lat_stdv_ns'

# CSV data
for f in $target/out/*.json; do
    echo ${target},$( json2csv $f )
done
