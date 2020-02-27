#!/bin/bash

module load fio

echo -n "SUDO password: "
read -s passwd

# stripe unit 64k to 512k
for su in 512k 256k 128k 64k; do

    # object size from 4m to 1m 
    for os in 4m 2m 1m; do

        dir=bs_su${su}_o${os}
        mkdir -p $dir

        # file size: 2g and 1m
        for fsize in 2g 1m; do

            # io type: seqr, seqw, randr
            for iotype in seqr seqw randr; do

                case $iotype in
                    seq*)
                        bsize=64k
                        ;;
                    rand*)
                        bsize=8k
                        ;;
                    *)
                        bsize=8k
                        ;;
                esac
         
                # number of client threads
                for thread in 128 64 32 16 8 4 2 1; do
         
                    echo "clean cache ..."
                    echo $passwd | sudo -S ./cleancache.sh
             
                    out=bs_su${su}_o${os}/${iotype}_s${fsize}_j${thread}.out
             
                    if [ ! -f ${out} ]; then
                        echo "wait for 10 seconds ..."
                        sleep 10
                        
                        echo -n "run test: su=${su} os=${os} fsize=${fsize} iotype=${iotype} bsize=${bsize} thread=${thread} output=$out ... "
                        FS_STRIPE_UNIT=${su} FS_OBJECT_SIZE=${os} BSIZE=${bsize} SIZE=$fsize NJOBS=${thread} fio ${iotype}.fio > $out 2>&1
         
                        if [ ${PIPESTATUS[0]} -eq 0 ]; then
                            echo "[success]"
                        else
                            echo "[failure]"
                        fi
                    else
                        echo -n "skip test: su=${su} os=${os} fsize=${fsize} iotype=${iotype} bsize=${bsize} thread=${thread} output=$out due to output exists."
                    fi
         
                done
         
            done

        done

    done

done
