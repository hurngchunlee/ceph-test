#!/bin/bash

function fsize2int() {
    case $1 in
        2g)
            fsize=2048
            ;;
        1m)
            fsize=1
            ;;
        *)
            fsize=0 # unexpected fsize
            ;;
    esac
    echo $fsize
}

function ciops () {

    case $1 in
        *k)
            iops=$( echo "$( echo $1 | sed 's/k//g' ) * 1024" | bc )
            ;;
        *m)
            iops=$( echo "$( echo $1 | sed 's/m//g' ) * 1024 * 1024" | bc )
            ;;
        *)
            iops=$1
            ;;
    esac
    echo $iops
}

function bwkib () {
    case $1 in
        *KiB/s)
            kib=$( echo $1 | sed 's/KiB\/s//g' )
            ;;
        *MiB/s)
            kib=$( echo "$( echo $1 | sed 's/MiB\/s//g' ) * 1024" | bc )
            ;;
        *GiB/s)
            kib=$( echo "$( echo $1 | sed 's/GiB\/s//g' ) * 1024 * 1024" | bc )
            ;;
        *)
            kib=0 # unexpected unit 
            ;;
    esac
    echo $kib
}

function latusec() {
    case $1 in
        usec)
            usec=$2
            ;;
        msec)
            usec=$( echo "$2 * 1000" | bc ) 
            ;;
        sec)
            usec=$( echo "$2 * 1000 * 1000" | bc ) 
            ;;
        *)
            usec=0 # unexpected unit 
            ;;
    esac
    echo $usec
}

function data2csv() {
    f=$1

    dir=$( echo $f | awk -F '/' '{print $1}' )
    fname=$( echo $f | awk -F '/' '{print $2}' )
    
    stripe_unit=$( echo $dir | awk -F '_' '{print $2}' | sed 's/su//g' | sed 's/k//g' )
    object_size=$( echo $dir | awk -F '_' '{print $3}' | sed 's/o//g' | sed 's/m//g' )
    
    io_type=$( echo $fname | awk -F '_' '{print $1}' )
    fsize=$( fsize2int $( echo $fname | awk -F '_' '{print $2}' | sed 's/s//g' ) )
    
    nthreads=$( echo $fname | awk -F '_' '{print $3}' | sed 's/j//g' | sed 's/.out//g' )
  
    # read performance 
    r_data=$( cat $f | grep '^  read:' )
    if [ $? -eq 0 ]; then
        r_iops=$( ciops $( echo $r_data | grep -o -e 'IOPS=\S*' | sed 's/IOPS=//g' | sed 's/,//g' ) )
        r_bw=$( bwkib $( echo $r_data | grep -o -e 'BW=\S*' | sed 's/BW=//g' ) )
        r_lat_unit=$( cat $f | grep -A 3 '^  read:' | tail -n 1 | grep -o -e '([u,m,\s]sec)' | sed 's/(//g' | sed 's/)//g' )
        r_lat=$( latusec $r_lat_unit $( cat $f | grep -A 3 '^  read:' | tail -n 1 | grep -o -e 'avg=[0-9\.]*' | sed 's/avg=//g' ) )
        echo $stripe_unit,$object_size,${io_type}:r,$fsize,$nthreads,$r_iops,$r_bw,$r_lat
    fi

    # write performance 
    w_data=$( cat $f | grep '^  write:' )
    if [ $? -eq 0 ]; then 
        w_iops=$( ciops $( echo $w_data | grep -o -e 'IOPS=\S*' | sed 's/IOPS=//g' | sed 's/,//g' ) )
        w_bw=$( bwkib $( echo $w_data  | grep -o -e 'BW=\S*' | sed 's/BW=//g' ) )
        w_lat_unit=$( cat $f | grep -A 3 '^  write:' | tail -n 1 | grep -o -e '([u,m,\s]sec)' | sed 's/(//g' | sed 's/)//g' )
        w_lat=$( latusec $r_lat_unit $( cat $f | grep -A 3 '^  write:' | tail -n 1 | grep -o -e 'avg=[0-9\.]*' | sed 's/avg=//g' ) )
        echo $stripe_unit,$object_size,${io_type}:w,$fsize,$nthreads,$w_iops,$w_bw,$w_lat
    fi
   
}

function header() {
    echo 'stripe_unit,object_size,io_type,fsize,nthreads,iops,bw,lat'
}

#### main program ####
if [ $# -lt 1 ]; then
    echo "Usage: $0 <file pattern>"
    exit 1
fi
header
for df in $@; do
    data2csv $df
done
